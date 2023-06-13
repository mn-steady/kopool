class CreateBubbleUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :bubble_uploads do |t|
      t.integer :tier, null: false, default: 0

      t.timestamps
    end
  end
end
