class Metric < ActiveRecord::Base
def self.search(search)
  if search
    where('"Text" LIKE ?', "%#{search}%")
  else
    scoped
  end
end
end
