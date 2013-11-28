require './utils/dictionary'

class Recommendations
  # Returns a Euclidean distance-based similiarity for two users
  def self.sim_distance(prefs, p1, p2)
    # Get the list of shared itens
    shared_items = prefs[p1].inject({}) do |hash, (key, value)|
      hash.merge("#{key}" => 1) if hash.is_a? Hash and prefs[p2].has_key? key
    end

     # if they have no ratings in common, return 0
    return 0 if shared_items.nil?

    # add up the squares of all the differences
    sum_of_squares = shared_items.keys.map{|item| (prefs[p1][item] - prefs[p2][item])**2}.inject(:+)

    return 1/(1+Math.sqrt(sum_of_squares))
  end

  # ================================================================================================
  # ================================================================================================

  # Returns the Pearson Correlation coefficient for two users
  def self.sim_pearson(prefs, p1, p2)
    shared_items = prefs[p1].inject({}) do |hash, (key, value)| 
      hash.merge("#{key}" => 1) if hash.is_a? Hash and prefs[p2].has_key? key
    end

    return 0 if shared_items.nil?

    n = shared_items.length

    # add up all the preferences
    sum1 = shared_items.keys.map{|item| prefs[p1][item]}.inject(:+)
    sum2 = shared_items.keys.map{|item| prefs[p2][item]}.inject(:+)

    # sum up the squares
    sum1Sqrt = shared_items.keys.map{|item| prefs[p1][item]**2}.inject(:+)
    sum2Sqrt = shared_items.keys.map{|item| prefs[p2][item]**2}.inject(:+)

    # sum up the products
    pSum = shared_items.keys.map{|item| prefs[p1][item] * prefs[p2][item]}.inject(:+)

    # calculate Pearson score
    num = pSum - (sum1 * sum2 / n)
    den = Math.sqrt((sum1Sqrt-(sum1**2)/n) * (sum2Sqrt-(sum2**2)/n))

    return 0 if den == 0

    r = num / den

    return r
  end

  # ================================================================================================
  # ================================================================================================

  # Returns the best matches for person from the prefs dictionary.
  # Number of results and similarity function are optional params.
  def self.top_matches(prefs, person, n = 5, algorithm = 'sim_pearson')
    scores = prefs.keys.map do |other|
      [Recommendations.send(algorithm, prefs, person, other), other] unless other == person
    end

    # sort the list so the highest scores appear at the top
    # and get the first n items of the sorted results, then convert to hash and return
    return scores.compact!.sort!{|a,b| b[0] <=> a[0]}.slice(0, n)
                 .inject({}){|hash, array| hash.merge(array[1] => array[0])}
  end
end