class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :message
      t.string :severity
      t.integer :stream_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :events
  end
end
