class PaginationProperties
  attr_accessor :page_offset, :page_limit, :item_count, :total_pages
  def initialize(page_offset, page_limit, item_count, total_pages)
    @page_offset = page_offset
    @page_limit = page_limit
    @item_count = item_count
    @total_pages = total_pages
  end
end
