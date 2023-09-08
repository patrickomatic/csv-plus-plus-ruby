# typed: strict
# frozen_string_literal: true

module CSVPlusPlus
  module Entities
    # Some helpful functions that can be mixed into a class to help building ASTs
    module ASTBuilder
      extend ::T::Sig

      sig do
        params(
          method_name: ::Symbol,
          args: ::T.untyped,
          kwargs: ::T.untyped,
          block: ::T.untyped
        ).returns(::CSVPlusPlus::Entities::Entity)
      end
      # Let the current class have functions which can build a given entity by calling it's type.  For example
      # +number(1)+, +variable(:foo)+
      #
      # @param method_name [Symbol] The +method_name+ to respond to
      # @param args [Array] The arguments to create the entity with
      # @param kwargs [Hash] The arguments to create the entity with
      #
      # @return [Entity, #super]
      # rubocop:disable Naming/BlockForwarding
      def method_missing(method_name, *args, **kwargs, &block)
        ::CSVPlusPlus::Entities.const_get(snake_case_to_class_name(method_name)).new(*args, **kwargs, &block)
      rescue ::NameError
        super
      end
      # rubocop:enable Naming/BlockForwarding

      sig { params(method_name: ::Symbol, _args: ::T.untyped).returns(::T::Boolean) }
      # Let the current class have functions which can build a given entity by calling it's type.  For example
      # +number(1)+, +variable(:foo)+
      #
      # @param method_name [Symbol] The +method_name+ to respond to
      # @param _args [::T.Untyped] The arguments to create the entity with
      #
      # @return [::T::Boolean, #super]
      def respond_to_missing?(method_name, *_args)
        ::CSVPlusPlus::Entities.const_get(snake_case_to_class_name(method_name))
        true
      rescue ::NameError
        super
      end

      private

      sig { params(method_name: ::Symbol).returns(::Symbol) }
      def snake_case_to_class_name(method_name)
        method_name.to_s.split('_').map(&:capitalize).join.to_sym
      end
    end
  end
end
