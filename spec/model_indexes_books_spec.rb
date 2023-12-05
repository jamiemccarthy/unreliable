# frozen_string_literal: true

RSpec.describe "model_indexes_books" do
  it "randomly selects from books with no order" do
    expect(Book.all.to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "randomly selects from books ordered by nonindexed column" do
    expect(Book.all.order(:subject).to_sql).to end_with(adapter_text('ORDER BY "books"."subject" ASC, RANDOM()'))
  end

  it "randomly selects from books ordered by unique column" do
    expect(Book.all.order(:isbn).to_sql).to end_with(adapter_text('ORDER BY "books"."isbn" ASC, RANDOM()'))
  end
end
