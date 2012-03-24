class RemoveImageUrlFromAuthorizations < ActiveRecord::Migration
  def up
    remove_column :authorizations, :image_url
      end

  def down
    add_column :authorizations, :image_url, :string
  end
end
