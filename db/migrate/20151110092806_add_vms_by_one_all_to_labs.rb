class AddVmsByOneAllToLabs < ActiveRecord::Migration[5.2]
  def change
    add_column :labs, :vms_by_one, :boolean,  :default=> true
  end
end
