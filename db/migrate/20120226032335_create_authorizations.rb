class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.string :image_url
      t.integer :user_id
      t.timestamps
    end
  end
end
