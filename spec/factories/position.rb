# typed: false
# frozen_string_literal: true

::FactoryBot.define do
  factory :position, class: ::CSVPlusPlus::Runtime::Position do
    transient do
      row_index { 0 }
      cell_index { nil }
      line_number { 1 }
      cell { nil }
      input { '' }
    end

    initialize_with { new(input) }

    after(:build) do |i, e|
      i.cell = e.cell
      i.cell_index = e.cell_index
      i.line_number = e.line_number
      i.row_index = e.row_index
    end
  end
end
