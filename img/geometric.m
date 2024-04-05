  1;

  ##############################################################################
  # FUNCTIONS
  ##############################################################################

  ##============================================================================
  #
  function y = geometric(T0, x, a)
    y = [T0];

    for i = 2:length(x)
      y = [y; a*y(i-1)];
    endfor
  endfunction


  ##############################################################################
  # SCRIPT
  ##############################################################################

  ## Generate x vector
  x = 0:1:1000;

  ## Initial temperature
  T0 = 500;

  ## Configure Plot
  set(0, "defaultlinelinewidth", 4);
  set(0, "defaultaxesfontsize", 16); % axes labels

  ## Plots
  figure(1);
  clf();
  plot(x, geometric(T0, x, 0.99));
  hold on;
  plot(x, geometric(T0, x, 0.95));
  plot(x, geometric(T0, x, 0.90));
  plot(x, geometric(T0, x, 0.80));
  hold off;

  ## Legend
  l = legend({'0.99', '0.95', '0.90', '0.80'});
  set(l, "fontsize", 20);

  ## Configure Plot
  ## set(0, "defaultlinelinewidth", 10);
  ## set(0, "defaultaxesfontsize", 32); % axes labels

  xlabel ("Time");
  ylabel ("Temperature");

  ## Output plot
  print(1, "geometric.png");
