plot_performances <- function(df, method = 'MRS1', metric = 'auROC', pthres){
  ori_vs_mm <- df %>%
    ggplot(aes(x = fct_rev(RiskType), y = !!sym(metric))) +
    geom_hline(yintercept = 0.5, linetype = 2, alpha) +
    geom_line(aes(group = dataset, color = better), alpha  = 0.3) +
    scale_x_discrete(expand = c(0.1, 0.1)) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    geom_point(aes(group = RiskType), height = 0, width = 0.2, alpha = 0.1, stroke = 0) +
    theme_bw() +
    viridis::scale_color_viridis(discrete = T, end = 0.9) +
    theme(legend.position = 'None') +
    labs(x = NULL)
  
  dens_df <- density(df$dif) %$% 
    data.frame(x = x, y = y) %>% 
    mutate(area = x >= 0) 
  
  dens_plot <- dens_df %>%
    ggplot(aes(x = x, ymin = 0, ymax = y, fill = area)) +
    geom_ribbon(alpha = 0.6) +
    geom_line(aes(y = y), alpha = 0.8) +
    theme_bw() +
    # labs(x = bquote(Delta~.(metric)~'('~.(method)~'- PRS)'), y = NULL) +
    labs(x = bquote(.(metric)[.(method)]~'-'~.(metric)[PRS]), y = NULL) +
    scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
    scale_y_continuous(expand = c(0, 0)) +
    expand_limits(y = max(dens_df$y)*1.05) +
    theme(legend.position = 'None',
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank()) +
    viridis::scale_fill_viridis(discrete = T, end = 0.9)
  
  cowplot::plot_grid(ori_vs_mm, dens_plot, align = 'h') %>%
    ggsave(filename = here('figs', paste(pthres, 'ori_vs', method, metric, '.pdf', sep = '_')), 
           height = 3, width = 5)
  cowplot::plot_grid(ori_vs_mm, dens_plot, align = 'h') %>%
    ggsave(filename = here('figs', paste(pthres, 'ori_vs', method, metric, '.svg', sep = '_')), 
           height = 3, width = 5)
  
}

# performances_info_gain <- function(method1, method2, xdf = info_gain, 
#                                    xlab = 'Total 2-way information gain'){
#   left_join(xdf, all_rocs, by = 'dataset') %>%
#     mutate(dif = !!sym(method1) - !!sym(method2)) %>%
#     ggplot(aes(x = value, y = dif)) +
#     geom_point(alpha = 0.3, stroke = 0) +
#     geom_smooth(color = 'grey30') +
#     theme_bw() +
#     labs(x = xlab, 
#          y = bquote(Delta~'auROC ('~.(method1)~'-'~.(method2)~')'))
# }
