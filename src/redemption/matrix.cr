require "./constants"

module Redemption

  macro define_matrices

    # For each number type and its associated abbreviation
    {% for klass, abrv in TYPE_HASH %}

      # For each possible number of rows
      {% for dim1 in DIM_ARRAY %}

        # For each possible number of columns
        {% for dim2 in DIM_ARRAY %}

          # Define a struct called Matrix<rows>x<columns><abbreviation>
          struct Matrix{{dim1}}x{{dim2}}{{abrv}}

            # For each of the rows in this matrix
            {% for i in 0...dim1 %}

              # For each of the columns in this matrix
              {% for j in 0...dim2 %}

                # Define an instance variable of the appropriate type called @v<row><column>
                @v{{i}}{{j}} : {{klass}}

              # End j iteration
              {% end %}

            # End i iteration
            {% end %}

            # If the number of rows matches the number of columns
            {% if dim1 == dim2 %}

              # Define a class method that returns an identity matrix
              def self.identity

                # Return a new rowsxcolumns identity Matrix of the appropriate type 
                Matrix{{dim1}}x{{dim2}}{{abrv}}.new({% for i in 0...dim1 %} {% for j in 0...dim2 %} {% if i == j %} 1, {% else %} 0, {% end %} {% end %} {% end %})
              end # end self.identity def

            # End dim1 == dim2 conditional.
            {% end %}

            # Define an initializer that accepts <rows> x <columns> objects of type Number
            def initialize({% for i in 0...dim1 %} {% for j in 0...dim2 %} n{{i}}{{j}} : Number, {% end %} {% end %} )

              # For each of the rows in this matrix
              {% for i in 0...dim1 %}

                # For each of the columns in this matrix
                {% for j in 0...dim2 %}

                  # Assign the corresponding instance variable to the converted argument
                  @v{{i}}{{j}} = n{{i}}{{j}}.to_{{abrv}}

                # End j iteration
                {% end %}

              # End i iteration
              {% end %}
            end # end initialize def

            # Define a method to return the values arranged as a tuple of tuples
            def values : Tuple({% for i in 0...dim1 %} Tuple({% for j in 0...dim2 %} {{klass}}, {% end %} ), {% end %} )

              # Return a Tuple that contains <rows> Tuples of size <columns>
              { {% for i in 0...dim1 %} { {% for j in 0...dim2 %} @v{{i}}{{j}}, {% end %} }, {% end %} }
            end # end values def

            # For each of the standard operators +, -, *, /
            {% for op in OPERATORS %}

              # Define a method for the given operator that accepts a single number
              def {{op.id}}(n : Number) : Matrix{{dim1}}x{{dim2}}{{abrv}}

                # Convert the argument to the appropriate number type
                num = n.to_{{abrv}}

                # Return a Matrix identically sized to this one that represents the result of the operation.
                Matrix{{dim1}}x{{dim2}}{{abrv}}.new({% for i in 0...dim1 %} {% for j in 0...dim2 %} @v{{i}}{{j}} {{op.id}} num, {% end %} {% end %})
              end # end op def

            # End op iteration
            {% end %}

            # For each of the number types and their associated abbreviations
            {% for qlass, qabrv in TYPE_HASH %}

              # If the Matrix is 4x4
              {% if dim1 == dim2 && dim1 == 4 %}

                # Define a method that creates a scaling Matrix from the given vector
                def self.scaling(other : Vector3{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}

                  # If the current Matrix's number type is different from the iterator's number type
                  {% if abrv != qabrv %}

                    # Retrieve the vector's values, converting them to the appropriate number type
                    ovals = other.to_{{abrv}}.values

                  # Otherwise
                  {% else %}

                    # Retrieve the vector's values
                    ovals = other.values

                  # End if abrv != qabrv conditional
                  {% end %}

                  # Return a new Matrix that represents the result of the operation
                  Matrix4x4{{abrv}}.new({% for i in 0...4 %} {% for j in 0...4 %} {% if i == j %} {% if i != 3 %} ovals[{{i}}], {% else %} 1, {% end %} {% else %} 0, {% end %} {% end %} {% end %})
                end # end scale def

                def scale(other : Vector3{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}
                  self * Matrix4x4{{abrv}}.scaling(other)
                end

                # Define a method that creates a translation matrix from the given vector
                def self.translation(other : Vector3{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}

                  # If the current Matrix's number type is different from the iterator's number type
                  {% if abrv != qabrv %}

                    # Retrieve the vector's values, converting them to the appropriate number type
                    ovals = other.to_{{abrv}}.values

                  # Otherwise
                  {% else %}

                    # Retrieve the vector's values
                    ovals = other.values

                  # End if abrv != qabrv conditional
                  {% end %}

                  # Return a new Matrix that represents the result of the operation
                  Matrix4x4{{abrv}}.new({% for i in 0...4 %} {% for j in 0...4 %} {% if i == j %} 1, {% elsif j == 3 %} ovals[{{i}}], {% else %} 0, {% end %} {% end %} {% end %})
                end # end translation def

                def translate(other : Vector3{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}
                  self * Matrix4x4{{abrv}}.translate(other)
                end
                
                # Define a method that creates a rotation Matrix from the given vector
                def self.rotation(ang : Number, axis : Vector3{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}

                  angle = ang.to_{{abrv}} 
                  sinangle = Math.sin(angle)
                  cosangle = Math.cos(angle)

                  # If the current Matrix's number type is different from the iterator's number type
                  {% if abrv != qabrv %}

                    # Retrieve the vector's values, converting them to the appropriate number type
                    axis_values = axis.to_{{abrv}}.normalize.values

                  # Otherwise
                  {% else %}

                    # Retrieve the vector's values
                    axis_values = axis.normalize.values

                  # End if abrv != qabrv conditional
                  {% end %}
                  Matrix4x4{{abrv}}.new(
                    cosangle + ((axis_values[0]**2) * (1 - cosangle)),
                    (axis_values[0] * axis_values[1] * (1 - cosangle)) - (axis_values[2] * sinangle),
                    (axis_values[0] * axis_values[2] * (1 - cosangle)) + (axis_values[1] * sinangle),
                    0,
                    (axis_values[1] * axis_values[0] * (1 - cosangle)) + (axis_values[2] * sinangle),
                    cosangle + ((axis_values[1]**2) * (1 - cosangle)),
                    (axis_values[1] * axis_values[2] * (1 - cosangle)) - (axis_values[0] * sinangle),
                    0,
                    (axis_values[2] * axis_values[0] * (1 - cosangle)) - (axis_values[1] * sinangle),
                    (axis_values[2] * axis_values[1] * (1 - cosangle)) + (axis_values[0] * sinangle),
                    cosangle + ((axis_values[2]**2) * (1 - cosangle)),
                    0,
                    0,
                    0,
                    0,
                    1
                  )
                end # end rotation def

                def rotate(ang : Number, axis : Vector3{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}
                  self * Matrix4x4{{abrv}}.rotation(ang, axis)
                end

              # End dim1 == dim2 && dim1 == 4 conditional
              {% end %}

              # If the current Matrix's number type is different from the iterator's number type
              {% if klass != qlass %}

                # Define a method to convert the matrix to another number type
                def to_{{qabrv}}

                  # Return the result of the operation
                  Matrix{{dim1}}x{{dim2}}{{qabrv}}.new({% for i in 0...dim1 %} {% for j in 0...dim2 %} @v{{i}}{{j}}.to_{{qabrv}} {% end %} {% end %})
                end # end convert def

              # End klass != qlass iteration
              {% end %}

              # For each possible number of rows
              {% for i in DIM_ARRAY %}

                # If this Matrix's number of rows is equal to the current value of i
                {% if dim1 == i %}

                  # Define a method to perform Matrix-Vector multiplication that returns the result of the operation
                  def *(other : Vector{{i}}{{qabrv}}) : Vector{{i}}{{abrv}}

                    # Retrieve this matrix's values as a tuple of tuples
                    svals = self.values

                    # If the current Matrix's number type is different from the iterator's number type
                    {% if abrv != qabrv %}

                      # Retrieve the given vector's values as a tuple, converted to the appropriate type
                      ovals = other.to_{{abrv}}.values

                    # Otherwise
                    {% else %}

                      # Retrieve the given vector's values as a tuple
                      ovals = other.values

                    # End abrv != qabrv conditional
                    {% end %}

                    # Define a new vector that represents the result of the multiplication
                    Vector{{i}}{{abrv}}.new({% for j in 0...dim1 %} svals[{{j}}].map_with_index { |sv, index| sv * ovals[index] }.sum, {% end %})
                  end # end * def

                # End dim1 == i conditional
                {% end %}

                # For each possible number of columns
                {% for j in DIM_ARRAY %}

                  # If this Matrix's number of rows is equal to the current value of j
                  {% if dim1 == j %}

                    # The Matrix dimensions currently represented by ixj are compatible with Matrix-Matrix multiplication

                    # Define a method to perform Matrix-Matrix multiplication that returns the result of the operation
                    def *(other : Matrix{{i}}x{{j}}{{qabrv}}) : Matrix{{dim1}}x{{j}}{{abrv}}

                      # Retrieve this matrix's values as a tuple of tuples
                      svals = self.values

                      # If the current Matrix's number type is different from the iterator's number type
                      {% if abrv != qabrv %}

                        # Retrieve the given matrix's values as a tuple of tuples, converted to the appropriate number type
                        ovals = other.to_{{abrv}}.values

                      # Otherwise
                      {% else %}

                      # Retrieve the given matrix's values as a tuple of tuples
                        ovals = other.values

                      # End abrv != qabrv conditional
                      {% end %}

                      # Define a new matrix that represents the result of the multiplication
                      Matrix{{dim1}}x{{j}}{{abrv}}.new({% for k in 0...dim1 %} {% for l in 0...j %} svals[{{k}}].map_with_index { |sv, index| sv * ovals[index][{{l}}] }.sum, {% end %} {% end %})
                    end # end * def

                  # End dim1 == j conditional
                  {% end %}

                # End j iteration
                {% end %}

              # End i iteration
              {% end %}

            # End qlass, qabrv iteration
            {% end %}

            # Define a method to convert the matrix to a string representation
            def to_s(io) : IO::FileDescriptor

              # Preface with a new line, to separate from other matrices
              io << "\n"

              # For each row in this matrix
              {% for i in 0...dim1 %}

                # Preface the row with a square bracket
                io << "[ " 

                # For each column in this matrix
                {% for j in 0...dim2 %}

                  # Print the value found at [i][j]
                  io << @v{{i}}{{j}} {% if j != dim2 - 1 %} << ", " {% end %}
                
                # End j iteration
                {% end %}

                # Print a new line, to separate from other matrices
                io << " ]\n"
              
              # End i iteration
              {% end %}
            end # end to_s def

          end # end struct

        # End dim2 iteration
        {% end %}

      # End dim1 iteration
      {% end %}

    # End klass, abrv iteration
    {% end %}
  end # end macro def

  # Call macro
  define_matrices
end