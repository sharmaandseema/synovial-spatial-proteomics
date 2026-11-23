# 09_plot_mask_overlay.R
# Display supplied mask boundaries over DNA1.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("figures")
)

region_path <- file.path(
  "data_raw", "data_tiff", "001-A-C", "A-Zone1a"
)

mask_path <- list.files(
  region_path, pattern = "_mask\\.tiff$", full.names = TRUE
)
stopifnot(length(mask_path) == 1)

dna <- tiff::readTIFF(
  file.path(region_path, "DNA1_Ir191.tiff"),
  as.is = TRUE
)
mask <- tiff::readTIFF(mask_path, as.is = TRUE)

stopifnot(
  is.matrix(dna),
  is.matrix(mask),
  identical(dim(dna), dim(mask)),
  all(is.finite(dna)),
  all(is.finite(mask))
)

cat("Number of positive mask labels:",
    length(unique(mask[mask > 0])), "\n")

# Identify boundaries where adjacent pixel labels differ
nr <- nrow(mask)
nc <- ncol(mask)
boundary <- matrix(FALSE, nr, nc)

row_change <- mask[-1, ] != mask[-nr, ]
col_change <- mask[, -1] != mask[, -nc]

boundary[-1, ] <- boundary[-1, ] | row_change
boundary[-nr, ] <- boundary[-nr, ] | row_change
boundary[, -1] <- boundary[, -1] | col_change
boundary[, -nc] <- boundary[, -nc] | col_change
boundary <- boundary & mask > 0

# Greyscale DNA with magenta boundaries
limit <- unname(quantile(dna, 0.995))
stopifnot(limit > 0)
grey <- pmin(pmax(dna / limit, 0), 1)

overlay <- array(0, dim = c(nr, nc, 3))
for (channel in 1:3) {
  layer <- grey
  layer[boundary] <- c(1, 0, 1)[channel]
  overlay[, , channel] <- layer
}

draw_overlay <- function() {
  plot(
    NA, xlim = c(0, nc), ylim = c(0, nr),
    asp = 1, axes = FALSE, xlab = "", ylab = "",
    main = "DNA1 + mask boundaries",
    xaxs = "i", yaxs = "i"
  )
  rasterImage(
    as.raster(overlay), 0, 0, nc, nr,
    interpolate = FALSE
  )
}

figure_path <- "figures/A-Zone1a_DNA1_mask_overlay.png"

png(figure_path, width = 700, height = 1500, res = 150)
draw_overlay()
dev.off()

draw_overlay()
cat("Figure saved:", file.exists(figure_path), "\n")

mask_path <- list.files(
  "data_raw/data_tiff/001-A-C/A-Zone1a",
  pattern = "_mask\\.tiff$",
  full.names = TRUE
)

stopifnot(length(mask_path) == 1)

mask <- tiff::readTIFF(mask_path, as.is = TRUE)

cat(
  "Positive mask labels:",
  length(unique(mask[mask > 0])),
  "\n"
)

cat(
  "Overlay figure saved:",
  file.exists("figures/A-Zone1a_DNA1_mask_overlay.png"),
  "\n"
)