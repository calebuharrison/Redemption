require "./constants"

module Redemption

  macro define_vectors

    # For each number type and its associated abbreviation
    {% for klass, abrv in TYPE_HASH %}

      # for each posible dimension of Vector
      {% for dim in DIM_ARRAY %}

        # Define a struct called Vector<dimensions><abbreviation>
        struct Vector{{dim}}{{abrv}}

          # For each value in such a Vector
          {% for i in 0...dim %}

            # Define an instance variable of the appropriate type
            @v{{i}} : {{klass}}

          # End i iteration
          {% end %}

          # Define an initializer that accepts <dimensions> objects of type Number
          def initialize({% for i in 0...dim %} n{{i}} : Number, {% end %})

            # For each value in the Vector
            {% for i in 0...dim %}

              # Assign the appropriate instance variable to the corresponding argument, converted to the appropriate type
              @v{{i}} = n{{i}}.to_{{abrv}}

            # End i iteration
            {% end %}
          end # end initialize def

          # Define a method to retrieve the values as a Tuple
          def values : Tuple({% for i in 0...dim %} {{klass}}, {% end %})

            # Return a Tuple of the this vector's values
            { {% for i in 0...dim %} @v{{i}}, {% end %} }
          end # end values def

          # For each of the standard operators +, -, *, /
          {% for op in OPERATORS %}

            # Define a method to perform the current operation with a single Number as an argument
            def {{op.id}}(n : Number) : Vector{{dim}}{{abrv}}

              # Convert the given number to the appropriate type
              num = n.to_{{abrv}}

              # Return a new vector that represents the result of the operation
              Vector{{dim}}{{abrv}}.new({% for i in 0...dim %} @v{{i}} {{op.id}} num, {% end %})
            end # end op def

          # End op iteration
          {% end %}

          # For each of the number types and their associated abbreviations
          {% for qlass, qabrv in TYPE_HASH %}

            # If the current vector's number type is different from the iterator's number type
            {% if abrv != qabrv %}
              
              # Define a method to convert the vector to another number type
              def to_{{qabrv}}

                # Return the result of the operation
                Vector{{dim}}{{qabrv}}.new({% for i in 0...dim %} @v{{i}}.to_{{qabrv}}, {% end %})
              end # end conversion def

            # End abrv != qabrv iteration
            {% end %}

            # For both the + and - operators
            {% for op in [:+, :-] %}

              # Define a method to perform the current operation with another Vector of identical dimensions as an argument
              def {{op.id}}(other : Vector{{dim}}{{qabrv}}) : Vector{{dim}}{{abrv}}

                # If the current vector's number type is different from the iterator's number type
                {% if abrv != qabrv %}

                  # Retrieve the given vector's values as a tuple
                  ovals = other.to_{{abrv}}.values

                # Otherwise
                {% else %}

                  # Retrieve the given vector's values as a tuple
                  ovals = other.values
                
                # End abrv != qabrv conditional
                {% end %}

                # Return a new vector that represents the result of the operation
                Vector{{dim}}{{abrv}}.new({% for i in 0...dim %} @v{{i}} {{op.id}} ovals[{{i}}], {% end %})
              end # end op def

            # End op iteration
            {% end %}

            # Define a method to calculate the dot product of two vectors of equal dimensions.
            def dot(other : Vector{{dim}}{{qabrv}}) : {{klass}}
          
              # Retrieve normalized values
              snv = self.normalize.values
          
              # If the current vector's number type is different from the iterator's number type
              {% if abrv != qabrv %}

                # Retrieve the other vector's normalized values, converted to the appropriate type
                onv = other.to_{{abrv}}.normalize.values

              # Otherwise
              {% else %}

                # Retrieve the other vector's normalized values
                onv = other.normalize.values

              # End abrv != qabrv conditional
              {% end %}
          
              # Return the result of the operation
              snv.map_with_index { |sv, i| sv * onv[i] }.sum
            end # end dot def
          
            # If the current Vector is a 3D Vector
            {% if dim == 3 %}
  
              # Define a method to calculate the cross product with another 3D Vector
              def cross(other : Vector3{{qabrv}}) : Vector3{{abrv}}
  
                # If the current vector's number type is different from the iterator's number type
                {% if abrv != qabrv %}

                  # Retrieve the other vector's values and convert them to the appropriate type
                  ovals = other.to_{{abrv}}.values

                # Otherwise
                {% else %}

                  # Retrieve the other vector's values
                  ovals = other.values

                # End abrv != qabrv conditional
                {% end %}
  
                # Return the result of the operation.
                Vector3{{abrv}}.new(@v1 * ovals[2] - @v2 * ovals[1], @v2 * ovals[0] - @v0 * ovals[2], @v0 * ovals[1] - @v1 * ovals[0])
              end # end cross def
            
            # End dim == 3 conditional
            {% end %}

          # End qlass, qabrv iteration
          {% end %}

          # Define a method to negate the current vector
          def negate : Vector{{dim}}{{abrv}}

            # Return the negated vector
            self.*(-1)
          end # end negate def

          # Define a method to calculate the magnitude of the current vector
          def magnitude : {{klass}}

            # Return the result of the operation
            Math.sqrt(values.map {|v| v**2}.sum)
          end # end magnitude def

          # Define a method to normalize the current vector
          def normalize : Vector{{dim}}{{abrv}}

            # Retrieve the vector's magnitude
            mag = self.magnitude

            # Return the result of the operation
            Vector{{dim}}{{abrv}}.new({% for i in 0...dim %} @v{{i}} / mag, {% end %})
          end # end normalize def

          # Define a method to return a string representation of this Vector
          def to_s(io) : IO::FileDescriptor

            # Preface the string with <{
            io << "<{ " 

            # For each of the values in the vector
            {% for i in 0...dim %} 

              # Print the value
              io << @v{{i}} 

              # If the value is not the last value
              {% if i != dim - 1 %} 

                # Print a comma to separate the values
                io << ", " 

              # Otherwise
              {% else %} 

                # Postfix the string with }>
                io << " }>" 
              
              # End i!= dim - 1 conditional
              {% end %} 

            # End i iteration
            {% end %}
          end # end to_s def

          # SWIZZLE OPERATORS

          # For each of the sets of swizzle operators.
          {% for quad, index in SWIZZLE_ARRAY %}

            # For each of the operators and their associated index
            {% for name_i, i in quad %}

              # If the operator index is less than the number of values in this vector
              {% if i < dim %}

                # Define a swizzle operator
                def {{name_i}} : {{klass}}

                  # Return the appropriate value
                  @v{{i}}
                end # end swizzle def

              # End i iteration
              {% end %}

              # For each of the operators and their associated index
              {% for name_j, j in quad %}

                # If both current operator indices are less than the number of values in this vector
                {% if i < dim && j < dim %}

                  # Define a swizzle operator
                  def {{name_i}}{{name_j}} : Vector2{{abrv}}

                    # Return the appropriate value
                    Vector2{{abrv}}.new(@v{{i}}, @v{{j}})
                  end # end swizzle def
                
                # End i < dim && j < dim conditional
                {% end %}

                # For each of the operators and their associated index
                {% for name_k, k in quad %}

                  # If  all three current operator indices are less than the number of values in this vector
                  {% if i < dim && j < dim && k < dim %}

                    # Define a swizzle operator
                    def {{name_i}}{{name_j}}{{name_k}} : Vector3{{abrv}}

                      # Return the appropriate value
                      Vector3{{abrv}}.new(@v{{i}}, @v{{j}}, @v{{k}})
                    end # end swizzle def

                  # End i < dim && j < dim && k < dim conditional
                  {% end %}

                  # For each of the operators and their associated index
                  {% for name_l, l in quad %}

                    # If all four current operator indices are less than the number of values in this vector
                    {% if i < dim && j < dim && k < dim && l < dim %}

                      # Define a swizzle operator
                      def {{name_i}}{{name_j}}{{name_k}}{{name_l}} : Vector4{{abrv}}

                        # Return the appropriate value
                        Vector4{{abrv}}.new(@v{{i}}, @v{{j}}, @v{{k}}, @v{{l}})
                      end # end swizzle def

                    # End i < dim %% j < dim && k < dim && l < dim conditional
                    {% end %}

                  # End name_l, l iteration
                  {% end %}

                # End name_k, k iteration
                {% end %}

              # End name_j, j iteration
              {% end %}

            # End name_i, i iteration
            {% end %}

          # End quad, index iteration
          {% end %}

        end # end struct def

      # End dim iteration
      {% end %}

    # End klass, abrv iteration
    {% end %}

  end # end macro def

  # Call macro
  define_vectors
end