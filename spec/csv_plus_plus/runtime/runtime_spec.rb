# typed: false
# frozen_string_literal: true

describe ::CSVPlusPlus::Runtime::Runtime do
  let(:variables) { {} }
  let(:functions) { {} }
  let(:position) { build(:position, cell:) }
  let(:scope) { build(:scope, functions:, variables:) }
  let(:runtime) { build(:runtime, position:, scope:) }

  describe '#resolve_cell_value' do
    let(:variables) { { foo: build(:number_one) } }
    let(:fn_call_celladjacent) { build(:fn_call, name: :celladjacent, arguments: [build(:reference, ref: 'A')]) }

    subject { runtime.resolve_cell_value(cell.ast) }

    context 'with a variable reference' do
      let(:cell) { build(:cell, value: '=foo', ast: build(:reference, ref: 'foo')) }

      it 'returns a copy of the ast with the value inserted' do
        expect(subject).to(eq(build(:number_one)))
      end
    end

    context 'with an undefined reference' do
      let(:cell) { build(:cell, value: '=itdoesnotexist', ast: build(:reference, ref: 'itdoesnotexist')) }

      it 'leaves the reference alone' do
        expect(subject).to(eq(cell.ast))
      end
    end

    context 'with a function reference' do
      let(:fn_body) do
        build(:fn_call, name: :add, arguments: [build(:reference, ref: 'a'), build(:reference, ref: 'b')])
      end
      let(:functions) { { foo: build(:fn, name: :foo, arguments: %i[a b], body: fn_body) } }

      let(:ast) { build(:fn_call, name: :foo, arguments: [build(:number_one), build(:number_two)]) }
      let(:cell) { build(:cell, value: '=foo', ast:) }

      it 'replaces the function and resolves the arguments' do
        expect(subject).to(eq(build(:fn_call, name: :add, arguments: [build(:number_one), build(:number_two)])))
      end
    end

    context 'with a builtin function reference (celladjacent)' do
      let(:ast) { fn_call_celladjacent }
      let(:cell) { build(:cell, value: '=CELLADJACENT(A)', ast:) }

      it 'replaces the function call with the builtin function' do
        expect(subject).to(eq(build(:reference, ref: 'A1')))
      end
    end

    context 'with a defined function that references a builtin' do
      let(:functions) { { foo: build(:fn, name: :foo, arguments: %i[], body: fn_call_celladjacent) } }

      let(:ast) { build(:fn_call, name: :foo, arguments: []) }
      let(:cell) { build(:cell, value: '=FOO()', ast:) }

      it 'resolves all the way down' do
        expect(subject).to(eq(build(:reference, ref: 'A1')))
      end
    end
  end
end
