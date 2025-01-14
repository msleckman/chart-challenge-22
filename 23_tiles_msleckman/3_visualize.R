source('3_visualize/src/save_lc_img_gif.R')
source('3_visualize/src/raster_plotting_w_ggplot.R')
source('3_visualize/src/lc_levelplot.R')
source('3_visualize/src/bar_plot.R')

p3_targets_list<- list(
  
  # Create output images for each year - tibble for p3_save_levelplot_map_frames target
  tar_target(
    gif_frames,
    tibble(raster = p2_reclassified_raster_list,
           seq = seq(1, length(p2_reclassified_raster_list))) # the sequence of the frames
  ),
  
  # Plotting
  ## Produce levelplot
  tar_target(
    p3_save_levelplot_map_frames,
    produce_lc_levelplot(raster_in = gif_frames$raster,
                   raster_frame = gif_frames$seq,
                   legend_df = legend_df,
                   reach_shp = NULL,
                   out_folder = "3_visualize/out/levelplot/"),
    pattern = map(gif_frames),
    format = 'file'
    ),

  ## Produce bar_plots as alternative to lined graphic
  tar_target(
    p3_save_barplot_frames,
    {lapply(X = all_years, FUN = function(x) stacked_bar_plot(counts = p2_raster_cell_count,
                              selected_year = x,
                              legend_df = legend_df, 
                              out_folder = '3_visualize/out/barplot/'))}
  ),
  
  tar_target(
    p3_gif_years,
    c('1900','1910','1920','1930','1940','1950','1960','1970','1980','1990','2001','2011','2019')
  ),
  tar_target(
    # this seems sort of weird, it's to be able to set the x-axis limits for the stacked bar without getting mapped
    p3_all_years, 
    p3_gif_years
  )
  ,
  ## create ggplot visual - Cee inspo!!! 

  tar_target(
    p3_save_map_frames_ggplot,
    raster_ploting_w_ggplot(
      raster_in = p2_downsamp_raster_list,
      reach_shp = p1_streams_polylines_drb,
      counts = p2_raster_cell_count,
      legend_df = legend_df,
      title = paste("Land Use and Land Cover Change in the DRB: ", p3_gif_years),
      years = p3_all_years, 
      chart_year = p3_gif_years,
      font_fam = "Dongle",
      out_folder = '3_visualize/out/ggplots',
      extent_map = drb_extent_map,
      drb_boundary = p1_drb_boundary),
    pattern = map(p2_downsamp_raster_list, p3_gif_years),
  format = "file",
  ),
  
  ## animate barplot maps - need to switch to tar_map 
  tar_target(
    p3_animate_ggplots_frames_gif,
    animate_frames_gif(frames = p3_save_map_frames_ggplot,
                       out_file = paste0('3_visualize/out/gifs/ggplot_gif_',today(),'.gif'),
                       reduce = FALSE, frame_delay_cs = 100, frame_rate = 60),
    format = 'file'
  ),


# Animations
## animate levelplot maps
tar_target(
  p3_animate_levelplot_frames_gif,
  animate_frames_gif(frames = p3_save_levelplot_map_frames,
                     out_file = paste0('3_visualize/out/gifs/levelplot_gif_',today(),'.gif'),
                     reduce = FALSE, frame_delay_cs = 100, frame_rate = 60),
  format = 'file'
),

## animate barplot maps - need to switch to tar_map 
tar_target(
  p3_animate_barplot_frames_gif,
  animate_frames_gif(frames = list.files('3_visualize/out/barplot/', full.names = TRUE, pattern = '.png$'),
                     out_file = paste0('3_visualize/out/gifs/barplot_gif_',today(),'.gif'),
                     reduce = FALSE, frame_delay_cs = 100, frame_rate = 60),
  format = 'file'
)

)

