class PaginationProperties
  attr_accessor :page_offset, :total_pages, :page_limit
  def initialize(page_offset, total_pages, page_limit)
    @page_offset = page_offset
    @total_pages = total_pages
    @page_limit = page_limit
  end
end
