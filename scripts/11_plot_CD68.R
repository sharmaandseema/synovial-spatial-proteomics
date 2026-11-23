# 11_plot_CD68.R
# Compare DNA1 and CD68 using separate display scales.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("figures"),
  dir.exists("results")
)

region_path <- "data_raw/data_tiff/001-A-C/A-Zone1a"

paths <- c(
  DNA1 = file.path(region_path, "DNA1_Ir191.tiff"),
  CD68 = file.path(region_path, "CD68_Tb159.tiff")
)

stopifnot(all(file.exists(paths)))

images <- lapply(
  paths,
  function(path) tiff::readTIFF(path, as.is = TRUE)
)

stopifnot(
  all(vapply(images, is.matrix, logical(1))),
  identical(dim(images$DNA1), dim(images$CD68)),
  all(vapply(
    images,
    function(x) all(is.finite(x) & x >= 0),
    logical(1)
  ))
)

# Calculate and save the brightness limits used for display
limits <- vapply(
  images,
  function(x) unname(quantile(x, 0.995)),
  numeric(1)
)

stopifnot(all(limits > 0))

write.csv(
  data.frame(
    channel = names(limits),
    display_upper_limit = unname(limits)
  ),
  "results/A-Zone1a_DNA1_CD68_display_limits.csv",
  row.names = FALSE
)

draw_channels <- function() {
  old_par <- par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))
  on.exit(par(old_par))
  
  for (label in names(images)) {
    x <- images[[label]]
    display <- pmin(x / limits[[label]], 1)
    
    plot(
      NA,
      xlim = c(0, ncol(x)),
      ylim = c(0, nrow(x)),
      asp = 1, axes = FALSE,
      xlab = "", ylab = "",
      main = paste("A-Zone1a:", label),
      xaxs = "i", yaxs = "i"
    )
    
    rasterImage(
      as.raster(display),
      0, 0, ncol(x), nrow(x),
      interpolate = FALSE
    )
  }
}

figure_path <- "figures/A-Zone1a_DNA1_CD68.png"

png(figure_path, width = 1200, height = 1500, res = 150)
draw_channels()
dev.off()

draw_channels()
print(limits)
cat("Figure saved:", file.exists(figure_path), "\n")