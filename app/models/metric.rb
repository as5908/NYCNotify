class Metric < ActiveRecord::Base
def self.search(search)
  if search
    search = search.to_s.downcase
    where('lower("Text") LIKE ?', "%#{search}%")
  else
    scoped
  end
end
end
