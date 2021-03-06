class CreateRedeems < ActiveRecord::Migration[4.2]
  def change
    create_table :redeems do |t|
      t.references :user
      t.references :coupon

      t.timestamps
    end
    add_index :redeems, :user_id
    add_index :redeems, :coupon_id
  end
end
