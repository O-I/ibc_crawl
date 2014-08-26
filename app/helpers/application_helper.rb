module ApplicationHelper
  def sortable(link_name, column, direction = 'DESC')
    link_to link_name, col: column, dir: direction
  end

  def shufflable(link_name)
    link_to link_name, mix: true
  end
end