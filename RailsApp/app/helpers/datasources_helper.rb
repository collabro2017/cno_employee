module DatasourcesHelper
  def access_level_display(datasource)
    title = "#{datasource.access_level} access".capitalize
    url = edit_access_level_datasource_path(datasource)
    
    link_to title, url, class: 'edit_access_level'
  end
end
