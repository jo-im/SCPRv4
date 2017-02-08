class PijQueriesCell < Cell::ViewModel
  def show
    render
  end

  def featured
    render
  end

  def asset_path(query)
    query.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-square.png"
  end

  def split_collection(array, num)
    last_num  = array.size - num
    first     = array.first(num)
    last      = array.last(last_num < 0 ? 0 : last_num)
    return [first, last]
  end
end
