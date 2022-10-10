# frozen_string_literal: true

ActiveRecord::Schema.define do
  # Implied primary key
  create_table "things" do |t|
    t.string "word"
  end

  # Explicit primary key
  create_table "dreams", primary_key: :dream_id do |t|
    t.string "subject"
  end

  # Two-column PRIMARY KEY index
  create_table("shelves", primary_key: %i[shelf_id shelf_position]) do |t|
    t.column :shelf_id, :string
    t.column :shelf_position, :integer
    t.column :contents, :string
  end

  # something with no primary key at all! how do I declare that?
end
