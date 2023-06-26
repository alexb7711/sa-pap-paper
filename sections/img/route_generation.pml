@startuml

title Route Schedule Generation

' Initialize
[*] --> Initialize : Given schedule parameters
Initialize : - Set initial temperate
Initialize : - Set cooling schedule
Initialize : - Define YAML path

' Import
Initialize --> Import
Import : Import schedule YAML file

' Load or generate schedule
Import --> run_prev
run_prev : - True: Load schedule from disk
run_prev : - False: Generate new schedule

'================================================================================
' True

' Buffer
run_prev --> Buffer : False
Buffer : - Charger data
Buffer : - Bus data
Buffer : - Time information
Buffer : - etc.

' Generate schedule
Buffer --> GenerateSchedule
state GenerateSchedule {
	' Number of visits
	NumberBusVisits : Randomly generate number of visits such that the total value adds up to N

	' Select times
	NumberBusVisits --> SelectTimes
	SelectTimes : - Arrival time (new)
	SelectTimes : - Arrival time (old)
	SelectTimes : - Departure time

	' Arrival time old
	SelectTimes --> ArrivalTimeOld
	ArrivalTimeOld : ArrivalTimeOld = ArrivalTimeNew

	' Final visit
	ArrivalTimeOld --> FinalVisit
	FinalVisit: final_visit = True if j == NumberBusVisit[b] else False
	
	' Departure time
	FinalVisit --> DepartureTime
	DepartureTime : - if not final visit: select a departure time between [min_rest,max_rest]
	DepartureTime : - else: set departure time as time horizon (T)

	' Arrival time new
	DepartureTime --> ArrivalTimeNew
	ArrivalTimeNew : - Chunk = T/NumberBusVisits
	ArrivalTimeNew : - ArrivalTimeNew = j*Chunk (j represents the jth NumberBusVisit)

	' Discharge
	ArrivalTimeNew --> Discharge
	Discharge : ArrivalTimeNew - DepartureTime
	
	' Loop back around
	Discharge --> SelectTimes : For each bus and for each visit

	' Sort
	Discharge --> SortByArrivalTime
	
	' Check feasibility
	SortByArrivalTime --> IsScheduleFeasible
	IsScheduleFeasible : Determine if the generated candidate solution is feasible

	' While loop
	IsScheduleFeasible --> NumberBusVisits : While the schedule is not feasible
	
}

' End
GenerateSchedule --> [*] : Return schedule

'================================================================================
' False

' Get file handlesr
run_prev --> FileHandler : True
FileHandler : Load binary file of parameters

' End
FileHandler --> [*] : Return schedule

@enduml
