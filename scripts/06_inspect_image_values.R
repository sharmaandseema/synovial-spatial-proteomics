# 06_inspect_image_values.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("results")
)

region_path <- file.path(
  "data_raw", "data_tiff", "001-A-C", "A-Zone1a"
)

mask_path <- list.files(
  region_path,
  pattern = "_mask\\.tiff$",
  full.names = TRUE
)

stopifnot(length(mask_path) == 1)

paths <- c(
  DNA1 = file.path(region_path, "DNA1_Ir191.tiff"),
  CD68 = file.path(region_path, "CD68_Tb159.tiff"),
  mask = mask_path
)

stopifnot(all(file.exists(paths)))

# Preserve stored integer values where supported
images <- lapply(
  paths,
  function(path) tiff::readTIFF(path, as.is = TRUE)
)

# Check that each image is a two-dimensional matrix
stopifnot(all(vapply(images, is.matrix, logical(1))))

image_checks <- do.call(
  rbind,
  lapply(names(images), function(label) {
    x <- images[[label]]
    finite_values <- x[is.finite(x)]
    
    data.frame(
      image = label,
      rows = nrow(x),
      columns = ncol(x),
      nonfinite_pixels = sum(!is.finite(x)),
      minimum = if (length(finite_values)) min(finite_values) else NA,
      maximum = if (length(finite_values)) max(finite_values) else NA,
      all_values_integer = all(is.finite(x)) &&
        all(x == round(x))
    )
  })
)

write.csv(
  image_checks,
  "results/A-Zone1a_image_checks.csv",
  row.names = FALSE
)

print(image_checks, row.names = FALSE)