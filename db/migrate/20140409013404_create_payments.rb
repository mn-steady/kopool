class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.integer :pool_entry_id
      t.datetime :paid_at
      t.decimal :amount

      t.timestamps
    end
  end
end
