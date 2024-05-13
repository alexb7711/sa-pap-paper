#!/usr/bin/python

import csv


################################################################################
# Functions
################################################################################


##==============================================================================
#
def calcConsumptionAssignment(p):
    slow = 30.0
    fast = 910.95

    consumption = 0
    assignment = 0

    with open(p) as f:
        next(f)
        csvreader = csv.reader(f)

        for row in csvreader:
            for i in range(0, len(row), 3):
                q = float(row[i])
                p = float(row[i + 2])

                if row[i] != "nan":
                    # Assignment
                    if q > 35 and q < 35 + 15:
                        assignment += 10 * q * slow
                    elif q > 35 + 15:
                        assignment += 10 * q * fast

                if row[i + 1] != "nan":
                    # Consumption
                    if q > 35 and q < 35 + 15:
                        consumption += 100 * p * slow
                    elif q > 35 + 15:
                        consumption += 100 * p * fast

    return consumption + assignment


##==============================================================================
#
def calcPenalty(p):
    penalty = 0
    thresh = 0.25 * 388

    with open(p) as f:
        next(f)
        csvreader = csv.reader(f)

        for row in csvreader:
            for i in range(0, len(row), 2):
                e = float(row[i + 1])

                if row[i + 1] != "nan":
                    if e <= thresh:
                        penalty += 5000 * (e - thresh) ** 2

    return penalty


##==============================================================================
#
def calcDemand(p):
    demand = 0
    peak = 0

    with open(p) as f:
        next(f)
        csvreader = csv.reader(f)

        # Find peak
        for row in csvreader:
            p = float(row[1])

            if p > peak:
                peak = p

        # Calculate demand
        demand = 10000 * peak

    return demand


################################################################################
# SCRIPT
################################################################################

J = calcConsumptionAssignment("./milp-schedule.csv")
J += calcPenalty("./milp-charge.csv")
J += calcDemand("./milp-power-usage.csv")
print("PAP: ", 1 * J)

J = calcConsumptionAssignment("./qm-schedule.csv")
J += calcPenalty("./qm-charge.csv")
J += calcDemand("./qm-power-usage.csv")
print("Qin: ", 1 * J)
