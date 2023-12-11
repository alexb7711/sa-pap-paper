  1;

  ##############################################################################
  # FUNCTIONS
  ##############################################################################

  ##============================================================================
  #
  function y = geometric(T0, x)
    a = 0.995;
    y = [T0];

    for i = 2:length(x)
      y = [y; a*y(i-1)];
    endfor
  endfunction

  ##============================================================================
  #
  function y = linear(T0, x)
    D = 0.5;
    y = [T0];

    for i = 2:length(x)
      y = [y; y(i-1) - D];
    endfor
  endfunction

  ##============================================================================
  #
  function y = exponential(T0, x)
    b = 0.01;
    y = [T0];

    for i = 2:length(x)
      y = [y; exp(b)*y(i-1)];
    endfor
  endfunction

  ##############################################################################
  # SCRIPT
  ##############################################################################

  ## Generate x vector
  x = 0:1:1000;

  ## Initial temperature
  T0 = 500;

  ## Plots
  tf = figure();
  hold on;
  plot(x, geometric(T0, x));
  plot(x, linear(T0, x));
  plot(x, exponential(T0, x));
  hold off;

  ## Configure Plot
  xlabel ("Time");
  ylabel ("Temperature");
  ylabel ("Temperature Functions");

  ## Output plot
  ## print(tf, "cool-func.pdf", "-dpdflatexstandalone");
  ## system ("pdflatex plot15_7");
