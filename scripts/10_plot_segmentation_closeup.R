# 10_plot_segmentation_closeup.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("figures")
)

region_path <- "data_raw/data_tiff/001-A-C/A-Zone1a"

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
  all(is.finite(mask)),
  min(dim(dna)) >= 150
)

# Select a central square using image row and column numbers
first_row <- floor((nrow(dna) - 150) / 2) + 1
first_col <- floor((ncol(dna) - 150) / 2) + 1

rows <- first_row + 0:149
cols <- first_col + 0:149

dna_crop <- dna[rows, cols]
mask_crop <- mask[rows, cols]

# Detect boundaries within the crop
boundary <- matrix(FALSE, 150, 150)

row_change <- mask_crop[-1, ] != mask_crop[-150, ]
col_change <- mask_crop[, -1] != mask_crop[, -150]

boundary[-1, ] <- boundary[-1, ] | row_change
boundary[-150, ] <- boundary[-150, ] | row_change
boundary[, -1] <- boundary[, -1] | col_change
boundary[, -150] <- boundary[, -150] | col_change
boundary <- boundary & mask_crop > 0

# Use the same brightness scale as the whole-region figure
limit <- unname(quantile(dna, 0.995))
stopifnot(limit > 0)

grey <- pmin(pmax(dna_crop / limit, 0), 1)

overlay <- array(0, dim = c(150, 150, 3))
for (channel in 1:3) {
  layer <- grey
  layer[boundary] <- c(1, 0, 1)[channel]
  overlay[, , channel] <- layer
}

draw_closeup <- function() {
  old_par <- par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))
  on.exit(par(old_par))
  
  for (panel in 1:2) {
    plot(
      NA, xlim = c(0, 150), ylim = c(0, 150),
      asp = 1, axes = FALSE, xlab = "", ylab = "",
      main = c("DNA1", "DNA1 + mask boundaries")[panel],
      xaxs = "i", yaxs = "i"
    )
    
    picture <- if (panel == 1) {
      as.raster(grey)
    } else {
      as.raster(overlay)
    }
    
    rasterImage(
      picture, 0, 0, 150, 150,
      interpolate = FALSE
    )
  }
}

figure_path <- "figures/A-Zone1a_segmentation_closeup.png"

png(figure_path, width = 1400, height = 750, res = 150)
draw_closeup()
dev.off()

draw_closeup()

cat("Crop rows:", range(rows), "\n")
cat("Crop columns:", range(cols), "\n")
cat("Figure saved:", file.exists(figure_path), "\n")