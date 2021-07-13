class PaginateService
  class << self
    def paginate(params, data)
      return {} if data.blank?
      {
        current_page: current_page(params),
        next_page: next_page(params, data),
        last_page: last_page(data)
      }
    end

    def current_page(params)
      params['page']&.to_i || 1
    end

    def next_page(params, data)
      page = current_page(params) + 1
      return nil if page >= last_page(data)
    end

    def last_page(data)
      data['total']&.to_i.fdiv(data['limit']&.to_i).ceil
    end
  end
end