class CreateWebStates < ActiveRecord::Migration
  def change
    create_table :web_states do |t|
      t.integer :week_id, :null => false
      t.string :broadcast_message, :null => false, :default => ""
      t.timestamps
    end
  end
end
