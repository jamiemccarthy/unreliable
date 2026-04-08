# frozen_string_literal: true

# eager_load fires a single LEFT OUTER JOIN query that goes through build_order
# and gets ORDER BY RANDOM() appended.
#
# preload fires the main query (ORDER BY RANDOM()) then a separate IN-list query
# for the association (also ORDER BY RANDOM(), since it's its own build_order call).
#
# includes delegates to preload when no association conditions are present, and
# to eager_load when conditions reference the association table.
#
# All three strategies are tested for correct SQL shape (via to_sql) and correct
# association loading (via execution).

RSpec.describe "eager_load, preload, includes" do
  # SQL shape — eager_load produces a single joinable query; to_sql reflects it fully.
  # preload/includes (no conditions) to_sql shows only the main query.

  it "eager_load appends random order on has_one" do
    expect(Dreamer.eager_load(:dream).to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end

  it "eager_load appends random order on has_many" do
    expect(Owner.eager_load(:cats).to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end

  it "preload main query appends random order" do
    expect(Dreamer.preload(:dream).to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end

  it "preload main query does not append random order when ordered by primary key" do
    expect(Dreamer.preload(:dream).order(:dreamer_id).to_sql).to end_with(
      adapter_rand('ORDER BY "dreamers"."dreamer_id" ASC')
    )
  end

  it "includes (no conditions) main query appends random order" do
    expect(Owner.includes(:cats).to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end

  it "includes (no conditions) main query does not append random order when ordered by primary key" do
    expect(Owner.includes(:cats).order(:id).to_sql).to end_with(
      adapter_rand('ORDER BY "owners"."id" ASC')
    )
  end

  it "includes (with association conditions) appends random order" do
    expect(Owner.includes(:cats).where(cats: {name: "foo"}).to_sql).to end_with(
      adapter_rand("ORDER BY RANDOM()")
    )
  end

  # Execution — verify associations load correctly despite the appended ORDER BY.

  context "with data" do
    before do
      @chuangmu = Owner.create!(name: "Chuangmu")
      @oisin = Owner.create!(name: "Oisin")
      Cat.create!(name: "Baku", owner: @chuangmu)
      Cat.create!(name: "Mara", owner: @chuangmu)
      Cat.create!(name: "Khidr", owner: @oisin)

      @gilgamesh = Dreamer.create!(name: "Gilgamesh")
      @penelope = Dreamer.create!(name: "Penelope")
      Dream.create!(subject: "cedar forest", dreamer: @gilgamesh)
      Dream.create!(subject: "eagle and goose", dreamer: @penelope)
    end

    after do
      Dream.delete_all
      Dreamer.delete_all
      Cat.delete_all
      Owner.delete_all
    end

    it "eager_load loads has_many associations correctly" do
      owners = Owner.eager_load(:cats).order(:name).to_a
      chuangmu = owners.find { |o| o.name == "Chuangmu" }
      oisin = owners.find { |o| o.name == "Oisin" }
      expect(chuangmu.cats.map(&:name).sort).to eq(%w[Baku Mara])
      expect(oisin.cats.map(&:name)).to eq(["Khidr"])
    end

    it "eager_load loads has_one associations correctly" do
      dreamers = Dreamer.eager_load(:dream).order(:name).to_a
      gilgamesh = dreamers.find { |d| d.name == "Gilgamesh" }
      penelope = dreamers.find { |d| d.name == "Penelope" }
      expect(gilgamesh.dream.subject).to eq("cedar forest")
      expect(penelope.dream.subject).to eq("eagle and goose")
    end

    it "preload loads associations correctly" do
      owners = Owner.preload(:cats).order(:name).to_a
      chuangmu = owners.find { |o| o.name == "Chuangmu" }
      expect(chuangmu.cats.map(&:name).sort).to eq(%w[Baku Mara])
    end

    it "includes loads associations correctly" do
      dreamers = Dreamer.includes(:dream).order(:name).to_a
      penelope = dreamers.find { |d| d.name == "Penelope" }
      expect(penelope.dream.subject).to eq("eagle and goose")
    end

    it "includes with association conditions filters and loads correctly" do
      owners = Owner.includes(:cats).where(cats: {name: "Baku"}).to_a
      expect(owners.map(&:name)).to eq(["Chuangmu"])
    end
  end
end
