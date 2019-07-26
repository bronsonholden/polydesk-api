class PaginationProperties
  attr_accessor :page_offset, :page_limit, :item_count, :total_pages
  def initialize(page_offset, page_limit, item_count)
    @page_offset = page_offset
    @page_limit = page_limit
    @item_count = item_count
    @total_pages = (item_count.to_f / page_limit).ceil
  end

  def generate
    {
      'page-offset' => @page_offset,
      'page-limit' => @page_limit,
      'item-count' => @item_count,
      'total-pages' => @total_pages
    }
  end
end
