class PaginationProperties
  attr_accessor :current_page, :total_pages, :limit_value
  def initialize(current_page, total_pages, limit_value)
    @current_page = current_page
    @total_pages = total_pages
    @limit_value = limit_value
  end
end
