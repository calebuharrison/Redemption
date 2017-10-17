require "./constants"

macro define_instance_variables(klass, dim1, dim2)
  {% for i in 0...dim1 %}
    {% for j in 0...dim2 %}
      @v{{i}}{{j}} : {{klass}}
    {% end %}
  {% end %}
end

macro define_identity_class_method(klass, abrv, dim)
  def self.identity : Matrix{{dim}}x{{dim}}{{abrv}}
    Matrix{{dim}}x{{dim}}{{abrv}}.new(
      {% for i in 0...dim %}
        {% for j in 0...dim %}
          {% if i == j %}
            1,
          {% else %}
            0,
          {% end %}
        {% end %}
      {% end %}
    )
  end
end

macro define_initializer(abrv, dim1, dim2)
  def initialize(
    {% for i in 0...dim1 %}
      {% for j in 0...dim2 %}
        n{{i}}{{j}} : Number,
      {% end %}
    {% end %}
  )
    {% for i in 0...dim1 %}
      {% for j in 0...dim2 %}
        @v{{i}}{{j}} = n{{i}}{{j}}.to_{{abrv}}
      {% end %}
    {% end %}
  end
end

macro define_to_a_methods(klass, dim1, dim2)
  def to_a : StaticArray(StaticArray({{klass}}, {{dim1}}), {{dim2}})
    StaticArray[
      {% for i in 0...dim1 %}
        StaticArray[
          {% for j in 0...dim2 %}
            @v{{i}}{{j}},
          {% end %}
        ],
      {% end %}
    ]
  end

  def flat : StaticArray({{klass}}, {{dim1 * dim2}})
    StaticArray [
      {% for i in 0...dim1 %}
        {% for j in 0...dim2 %}
          @v{{i}}{{j}},
        {% end %}
      {% end %}
    ]
  end
end

macro define_scalar_operation(abrv, dim1, dim2, op)
  def {{op.id}}(n : Number) : Matrix{{dim1}}x{{dim2}}{{abrv}}
    num = n.to_{{abrv}}
    Matrix{{dim1}}x{{dim2}}{{abrv}}.new(
      {% for i in 0...dim1 %}
        {% for j in 0...dim2 %}
          @v{{i}}{{j}} {{op.id}} num,
        {% end %}
      {% end %}
    )
  end
end

macro define_scaling_class_methods(abrv, qabrv, dim)
  def self.scaling(vec : Vector3{{qabrv}}) : Matrix{{dim}}x{{dim}}{{abrv}}
    vec_vals = vec.to_{{abrv}}.to_a
    Matrix{{dim}}x{{dim}}{{abrv}}.new(
      {% for i in 0...dim %}
        {% for j in 0...dim %}
          {% if i == j %}
            {% if j != 3 %}
              vec_vals[{{i}}]
            {% else %}
              1
            {% end %}
          {% else %}
            0
          {% end %}
          ,
        {% end %}
      {% end %}
    )
  end

  def self.scaling(v0 : Number, v1 : Number, v2 : Number) : Matrix{{dim}}x{{dim}}{{abrv}}
    self.scaling(Vector3{{abrv}}.new(v0, v1, v2))
  end
end

macro define_scale_methods(abrv, qabrv, dim)
  def scale(vec : Vector3{{qabrv}}) : Matrix{{dim}}x{{dim}}{{abrv}}
    self * Matrix{{dim}}x{{dim}}{{abrv}}.scaling(vec)
  end

  def scale(v0 : Number, v1 : Number, v2 : Number) : Matrix{{dim}}x{{dim}}{{abrv}}
    self.scale(Vector3{{abrv}}.new(v0, v1, v2))
  end
end

macro define_translation_class_methods(abrv, qabrv, dim)
  def self.translation(vec : Vector3{{qabrv}}) : Matrix{{dim}}x{{dim}}{{abrv}}
    vec_vals = vec.to_{{abrv}}.to_a
    Matrix{{dim}}x{{dim}}{{abrv}}.new(
      {% for i in 0...dim %}
        {% for j in 0...dim %}
          {% if i == j %}
            1
          {% elsif j == 3 %}
            vec_vals[{{i}}]
          {% else %}
            0
          {% end %}
          ,
        {% end %}
      {% end %}
    )
  end

  def self.translation(v0 : Number, v1 : Number, v2 : Number) : Matrix{{dim}}x{{dim}}{{abrv}}
    self.translation(Vector3{{abrv}}.new(v0, v1, v2))
  end
end

macro define_translate_methods(abrv, qabrv, dim)
  def translate(vec : Vector3{{qabrv}}) : Matrix{{dim}}x{{dim}}{{abrv}}
    self * Matrix{{dim}}x{{dim}}{{abrv}}.translation(vec)
  end

  def translate(v0 : Number, v1 : Number, v2 : Number) : Matrix{{dim}}x{{dim}}{{abrv}}
    self.translate(Vector3{{abrv}}.new(v0, v1, v2))
  end
end

macro define_rotation_class_methods(abrv, qabrv, dim)
  def self.rotation(ang : Number, axis : Vector3{{qabrv}}) : Matrix{{dim}}x{{dim}}{{abrv}}
    axis_values = axis.to_{{abrv}}.normalize.to_a
    angle = ang.to_{{abrv}}
    sinangle = Math.sin(angle)
    cosangle = Math.cos(angle)
    difference = 1 - cosangle

    Matrix{{dim}}x{{dim}}{{abrv}}.new(
      cosangle + ((axis_values[0]**2) * difference),
      (axis_values[0] * axis_values[1] * difference) - (axis_values[2] * sinangle),
      (axis_values[0] * axis_values[2] * difference) + (axis_values[1] * sinangle),
      0,
      (axis_values[1] * axis_values[0] * difference) + (axis_values[2] * sinangle),
      cosangle + ((axis_values[1]**2) * difference),
      (axis_values[1] * axis_values[2] * difference) - (axis_values[0] * sinangle),
      0,
      (axis_values[2] * axis_values[0] * difference) - (axis_values[1] * sinangle),
      (axis_values[2] * axis_values[1] * difference) + (axis_values[0] * sinangle),
      cosangle + ((axis_values[2]**2) * difference),
      0,
      0,
      0,
      0,
      1 
    )
  end

  def self.rotation(ang : Number, axis0 : Number, axis1 : Number, axis2 : Number) : Matrix{{dim}}x{{dim}}{{abrv}}
    self.rotation(ang, Vector3{{abrv}}.new(axis0, axis1, axis2))
  end
end

macro define_rotate_methods(abrv, qabrv, dim)
  def rotate(ang : Number, axis : Vector3{{qabrv}}) : Matrix{{dim}}x{{dim}}{{abrv}}
    self * Matrix{{dim}}x{{dim}}{{abrv}}.rotation(ang, axis)
  end

  def rotate(ang : Number, axis0 : Number, axis1 : Number, axis2 : Number) : Matrix{{dim}}x{{dim}}{{abrv}}
    self.rotate(ang, Vector3{{abrv}}.new(axis0, axis1, axis2))
  end
end

macro define_orthographic_class_method(abrv, dim)
  def self.orthographic(
    left : Number,
    right : Number,
    bottom : Number,
    top : Number,
    near : Number,
    far : Number
  ) : Matrix{{dim}}x{{dim}}{{abrv}}
    l = left.to_{{abrv}}
    r = right.to_{{abrv}}
    b = bottom.to_{{abrv}}
    t = top.to_{{abrv}}
    n = near.to_{{abrv}}
    f = far.to_{{abrv}}
    Matrix{{dim}}x{{dim}}{{abrv}}.new(
      2 / (r - l),
      0,
      0,
      -1 * ((r + l) / (r - l)),
      0,
      2 / (t - b),
      0,
      -1 * ((t + b) / (t - b)),
      0,
      0,
      -2 / (f - n),
      -1 * ((f + n) / (f - n)),
      0,
      0,
      0,
      1
    )
  end
end

macro define_perspective_class_method(abrv, dim)
  def self.perspective(
    fov : Number,
    aspect : Number,
    near : Number,
    far : Number
  )
    n = near.to_{{abrv}}
    f = far.to_{{abrv}}
    t = n * Math.tan(fov.to_{{abrv}})
    r = t * aspect.to_{{abrv}}
    Matrix{{dim}}x{{dim}}{{abrv}}.new(
      n / r,
      0,
      0,
      0,
      0,
      n / t,
      0,
      0,
      0,
      0,
      ((-1 * f) + n) / (f - n),
      ((-2 * f) * n) / (f - n),
      0,
      0,
      -1,
      0
    )
  end
end

macro define_transpose_method(abrv, dim1, dim2)
  def transpose : Matrix{{dim2}}x{{dim1}}{{abrv}}
    Matrix{{dim2}}x{{dim1}}{{abrv}}.new(
      {% for i in 0...dim1 %}
        {% for j in 0...dim2 %}
          @v{{j}}{{i}},
        {% end %}
      {% end %}
    )
  end
end

macro define_type_conversion_method(qabrv, dim1, dim2)
  def to_{{qabrv}} : Matrix{{dim1}}x{{dim2}}{{qabrv}}
    Matrix{{dim1}}x{{dim2}}{{qabrv}}.new(
      {% for i in 0...dim1 %}
        {% for j in 0...dim2 %}
          @v{{i}}{{j}}.to_{{qabrv}},
        {% end %}
      {% end %}
    )
  end
end

macro define_matrix_vector_multiplication_method(abrv, qabrv, dim1, dim2)
  def *(vec : Vector{{dim1}}{{qabrv}}) : Vector{{dim1}}{{abrv}}
    svals = self.to_a
    vec_vals = vec.to_{{abrv}}.to_a
    Vector{{dim1}}{{qabrv}}.new(
      {% for i in 0...dim1 %}
        svals[{{i}}].map_with_index { |sv, index| sv * vec_vals[index] }.sum,
      {% end %}
    )
  end
end

macro define_matrix_matrix_multiplication_method(abrv, qabrv, dim1, other_rows, dim2)
  def *(other : Matrix{{other_rows}}x{{dim2}}{{qabrv}}) : Matrix{{dim1}}x{{dim2}}{{abrv}}
    svals = self.to_a
    ovals = other.to_{{abrv}}.to_a
    Matrix{{dim1}}x{{dim2}}{{abrv}}.new(
      {% for i in 0...dim1 %}
        {% for j in 0...dim2 %}
          svals[{{i}}].map_with_index { |sv, index| sv * ovals[index][{{j}}] }.sum,
        {% end %}
      {% end %}
    )
  end
end

macro define_to_s_method(dim1, dim2)
  def to_s(io) : IO::FileDescriptor
    io << "\n"
    {% for i in 0...dim1 %}
      io << "[ " 
      {% for j in 0...dim2 %}
        io << @v{{i}}{{j}} {% if j != dim2 - 1 %} << ", " {% end %}
      {% end %}
      io << " ]\n"
    {% end %} 
  end
end

macro define_matrix(klass, abrv, dim1, dim2)
  struct Matrix{{dim1}}x{{dim2}}{{abrv}}
    define_instance_variables({{klass}}, {{dim1}}, {{dim2}})
    define_initializer({{abrv}}, {{dim1}}, {{dim2}})
    define_to_a_methods({{klass}}, {{dim1}}, {{dim2}})
    define_to_s_method({{dim1}}, {{dim2}})
    define_transpose_method({{abrv}}, {{dim1}}, {{dim2}})

    {% for op in OPERATORS %}
      define_scalar_operation({{abrv}}, {{dim1}}, {{dim2}}, {{op}})
    {% end %}

    # if the matrix is 2x2, 3x3, or 4x4
    {% if dim1 == dim2 %}
      define_identity_class_method({{klass}}, {{abrv}}, {{dim1}})

      # if the matrix is 4x4
      {% if dim1 == 4 %}
        {% for qlass, qabrv in TYPE_HASH %}
          define_scaling_class_methods({{abrv}}, {{qabrv}}, {{dim1}})
          define_scale_methods({{abrv}}, {{qabrv}}, {{dim1}})
          define_translation_class_methods({{abrv}}, {{qabrv}}, {{dim1}})
          define_translate_methods({{abrv}}, {{qabrv}}, {{dim1}})
          define_rotation_class_methods({{abrv}}, {{qabrv}}, {{dim1}})
          define_rotate_methods({{abrv}}, {{qabrv}}, {{dim1}})
          define_orthographic_class_method({{abrv}}, {{dim1}})
          define_perspective_class_method({{abrv}}, {{dim1}})
        {% end %}
      {% end %}
    {% end %}

    {% for qlass, qabrv in TYPE_HASH %}
      define_type_conversion_method({{qabrv}}, {{dim1}}, {{dim2}})
      {% for i in DIM_ARRAY %}
        {% if i == dim1 %}
          define_matrix_vector_multiplication_method({{abrv}}, {{qabrv}}, {{dim1}}, {{dim2}})
        {% end %}
        {% for j in DIM_ARRAY %}
          define_matrix_matrix_multiplication_method({{abrv}}, {{qabrv}}, {{dim1}}, {{i}}, {{dim2}})
        {% end %}
      {% end %}
    {% end %}
  end
end

module Redemption
  {% for klass, abrv in TYPE_HASH %}
    {% for dim1 in DIM_ARRAY %}
      {% for dim2 in DIM_ARRAY %}
        define_matrix({{klass}}, {{abrv}}, {{dim1}}, {{dim2}})
      {% end %}
    {% end %}
  {% end %}
end