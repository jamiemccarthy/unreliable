# frozen_string_literal: true

ActiveRecord::Schema.define do
  # No primary key
  create_table "books", id: false do |t|
    t.string "subject"
    t.string "isbn", index: {unique: true}
  end

  # Implied primary key
  create_table "cats" do |t|
    t.string "name"
    t.timestamp "updated_at"
  end

  # Explicit primary key
  create_table "dreams", primary_key: :dream_id do |t|
    t.string "subject"
    t.references :dreamer
  end

  # Association with dreams, where primary keys have different names
  create_table "dreamers", primary_key: :dreamer_id do |t|
    t.string :name
  end

  # Association with cats, where primary keys have same names
  create_table "owners" do |t|
    t.string :name
    t.references :cat
  end

  # Two-column primary key index
  create_table("shelves", primary_key: %i[shelf_id shelf_position]) do |t|
    t.column :shelf_id, :string
    t.column :shelf_position, :integer
    t.column :contents, :string
  end
end
