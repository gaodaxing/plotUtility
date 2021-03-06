#' Plot utilities.
#'
#' @param graphicObject The plot object to be saved. If missing, the most recently depicted plot will be saved.
#' @param outputFileName The name of the exported PDF file.
#' @param width A width.
#' @param height A height.
#' @param gsEmbetFont Logical. Whether fonts should be embedded using ghostscript.
#' @param gsPath A path to the Ghostscript exe file.
#' @param gsOption A character vector containing options to Ghostscript.
#' @export
#' @rdname Utility_Plot
#' @name Utility_Plot
savePDF <- function(
  graphicObject=NULL,
  outputFileName="plot.pdf",
  width=8,
  height=5,
  gsEmbetFont=T,
  gsPath="C:/gs/gs9.16/bin/gswin32c.exe",
  gsOption="-sFONTPATH=C:/Windows/Fonts -dCompressFonts=true -dSubsetFonts=false -dEmbedAllFonts=true"
){
  OS <- Sys.info()[["sysname"]]
  if(OS=="Windows"){
    grDevices::windowsFonts(Helvetica=grDevices::windowsFont("Helvetica"))
  }
  out <- ifelse(stringr::str_detect(outputFileName, ".pdf$"), outputFileName, paste0(outputFileName, ".pdf"))
  if(is.null(graphicObject)){
    graphicObject <- try(grDevices::recordPlot(), silent=T)
    if(identical(class(graphicObject), "try-error")){
      graphicObject <- ggplot2::last_plot()
    }
    if(is.null(graphicObject)){
      return("No plot can be retrieved!")
    }
  }
  print(graphicObject)
  grDevices::dev.copy2pdf(file=out, width=width, height=height, pointsize=12, family="Helvetica", bg="transparent", out.type="pdf")
  grDevices::dev.off()
  if(gsEmbetFont){
    Sys.setenv(R_GSCMD=gsPath)
    grDevices::embedFonts(out, outfile=out, options=gsOption)
  }
  print(normalizePath(out))
  return(invisible(NULL))
}

#' @export
#' @rdname Utility_Plot
#' @name Utility_Plot
savePPTX <- function(
  graphicObject=NULL,
  outputFileName="plot.pptx",
  width=8,
  height=5
){
  out <- ifelse(stringr::str_detect(outputFileName, ".pptx$"), outputFileName, paste0(outputFileName, ".pptx"))
  if(is.null(graphicObject)){
    graphicObject <- try(grDevices::recordPlot(), silent=T)
    if(identical(class(graphicObject), "try-error")){
      graphicObject <- ggplot2::last_plot()
    }
    if(is.null(graphicObject)){
      return("No plot can be retrieved!")
    }
  }
  print(graphicObject)
  doc <- officer::read_pptx()
  doc <- officer::add_slide(doc, layout="Blank", master="Office Theme")
  doc <- rvg::ph_with_vg_at(doc, code=print(graphicObject), left=1, top=1, width=width, height=height)
  print(doc, target=out)
  grDevices::dev.off()
  print(normalizePath(out))
  return(invisible(NULL))
}

#' Statistical significance
#' @param p A p-value, or a set of p-values.
#' @export
#' @rdname Utility_Plot_ggplot-significance
#' @name Utility_Plot_ggplot-significance
format_pvalue <- function(p){
  stringr::str_replace(paste0("P=",format.pval(p, 1)), "=<", "<")
}

#' Publication-ready ggplot scales
#' @export
#' @rdname Utility_Plot_ggplot-scales
#' @name Utility_Plot_ggplot-scales
scale_color_Publication <- function() {
  discrete_scale("color", "Publication", scales::manual_pal(values=c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")))
}

#' @export
#' @rdname Utility_Plot_ggplot-scales
#' @name Utility_Plot_ggplot-scales
scale_colour_Publication <- function() {
  discrete_scale("colour", "Publication", scales::manual_pal(values=c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")))
}

#' @export
#' @rdname Utility_Plot_ggplot-scales
#' @name Utility_Plot_ggplot-scales
scale_fill_Publication <- function() {
  discrete_scale("fill", "Publication", scales::manual_pal(values=c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")))
}

#' A publication-ready ggplot theme
#' @param base_size The base font size.
#' @export
#' @rdname Utility_Plot_ggplot-theme
#' @name Utility_Plot_ggplot-theme
theme_Publication <-
  function(base_size=18) {
    OS <- Sys.info()[["sysname"]]
    if(OS=="Windows"){
      # Translation of a device-independent R graphics font family name to a windows font description
      grDevices::windowsFonts(Helvetica=grDevices::windowsFont("Helvetica"))
    }

    # The preset ggplot parameters
    .pt <- 1 / 0.352777778
    .len0_null <- function(x) {
      if (length(x) == 0)  NULL
      else                 x
    }

    # A ggplot theme for the "L" (left + bottom) border
    theme_L_border <- function(colour = "black", size = 1, linetype = 1) {
      # use with e.g.: ggplot(...) + theme( panel.border=theme_L_border() ) + ...
      structure(
        list(colour = colour, size = size, linetype = linetype),
        class = c("theme_L_border", "element_blank", "element")
      )
    }
    element_grob.theme_L_border <- function(
      element, x = 0, y = 0, width = 1, height = 1,
      colour = NULL, size = NULL, linetype = NULL,
      ...) {
      gp <- gpar(lwd = .len0_null(size * .pt), col = colour, lty = linetype)
      element_gp <- gpar(lwd = .len0_null(element$size * .pt), col = element$colour, lty = element$linetype)
      polylineGrob(
        x = c(x+width, x, x), y = c(y,y,y+height), ..., default.units = "npc",
        gp = utils::modifyList(element_gp, gp)
      )
    }

    # A combined set of ggplot theme options
    (
      ggthemes::theme_foundation(base_size = base_size, base_family = "Helvetica")
      + theme(
        plot.title = element_text(
          face = "bold",
          size = rel(1.2), hjust = 0.5
        ),
        text = element_text(),
        plot.background = element_rect(colour = NA),
        plot.margin = unit(c(10,5,5,5), "mm"),
        panel.background = element_rect(colour = NA),
        panel.border = theme_L_border(),
        panel.grid.major = element_line(size = .5, colour = "#f0f0f0"),
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"),
        axis.title.x = element_text(vjust = -0.25),
        axis.title.y = element_text(vjust = 1.5),
        axis.text = element_text(),
        axis.line = element_line(size = .7, colour = "black"),
        axis.ticks = element_line(),
        legend.position = "right",
        legend.direction = "vertical",
        legend.background = element_blank(),
        legend.key = element_rect(colour = NA),
        legend.key.size = unit(0.7, "cm"),
        legend.spacing = unit(0.5, "cm"),
        legend.title = element_text(face = "bold"),
        strip.background = element_rect(colour = "#f0f0f0", fill = "#f0f0f0"),
        strip.text = element_text(face = "bold")
      )
    )
  }

