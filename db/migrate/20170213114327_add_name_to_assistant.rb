class AddNameToAssistant < ActiveRecord::Migration
  def change
    add_column :assistants, :name, :string
  end
end
