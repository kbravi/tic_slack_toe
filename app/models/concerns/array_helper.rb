module ArrayHelper
  # Groups array elements and sorts (descending) by count
  # Input: [1,2,2,3,1,2]
  # Ouput: [[2,3],[1,2],[3,1]]
  def array_group_count_sort(array)
    h = Hash.new(0)
    array.each{|x| h[x] = h[x].to_i + 1}
    return h.sort_by{|k,v| -v}
  end
end
