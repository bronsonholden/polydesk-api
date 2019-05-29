class PaginationGenerator
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 25

  attr_accessor :url, :hash
  attr_reader :page, :total_pages, :per_page

  def initialize(request:, paginated:, count: nil)
    @url = request.base_url + request.path
    @page = paginated.page_offset
    @total_pages = paginated.total_pages
    @per_page = paginated.page_limit
    @hash = {
      links: {},
      meta: {
        page_offset: paginated.page_offset,
        total_pages: paginated.total_pages,
        count: count || paginated.count
      }
    }
  end

  def generate
    if page > 1
      hash[:links][:first] = generate_url(1)
      hash[:links][:prev] = generate_url(page - 1)
    end

    hash[:links][:self] = generate_url(page)

    if page < total_pages
      hash[:links][:next] = generate_url(page + 1)
      hash[:links][:last] = generate_url(total_pages)
    end

    hash
  end

  def generate_url(at_page)
    [ url, url_params(at_page) ].join('?')
  end

  def url_params(at_page)
    url_params = {}
    url_params[:page] = at_page
    url_params[:limit] = per_page
    url_params.to_query
  end

  def custom_per_page?
    per_page != 0 && per_page != DEFAULT_PER_PAGE
  end

  def custom_page?
    page != 0 && age != DEFAULT_PAGE
  end
end
