module SortUtils
  def parse_sort_type(sort_type)
    last_index_of_underscore = sort_type.rindex('_')
    length = sort_type.length
    sort_type[0,last_index_of_underscore] + ' ' + sort_type[last_index_of_underscore+1, length]
  end
end