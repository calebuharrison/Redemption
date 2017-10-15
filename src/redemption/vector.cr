require "./constants"

macro define_instance_variables(klass, dim)
  {% for i in 0...dim %}
    @v{{i}} : {{klass}}
  {% end %}
end

macro define_initializer(abrv, dim)
  def initialize(
    {% for i in 0...dim %}
      n{{i}} : Number,
    {% end %}
  )
    {% for i in 0...dim %}
      @v{{i}} = n{{i}}.to_{{abrv}}
    {% end %}
  end
end

macro define_to_a_method(klass, dim)
  def to_a : StaticArray({{klass}}, {{dim}})
    StaticArray[
      {% for i in 0...dim %}
        @v{{i}},
      {% end %}
    ]
  end
end

macro define_scalar_operation(op, abrv, dim)
  def {{op.id}}(n : Number) : Vector{{dim}}{{abrv}}
    num = n.to_{{abrv}}
    Vector{{dim}}{{abrv}}.new(
      {% for i in 0...dim %}
        @v{{i}} {{op.id}} num,
      {% end %}
    )
  end
end

macro define_type_conversion_method(qabrv, dim)
  def to_{{qabrv}} : Vector{{dim}}{{qabrv}}
    Vector{{dim}}{{qabrv}}.new(
      {% for i in 0...dim %}
        @v{{i}}.to_{{qabrv}},
      {% end %}
    )
  end
end

macro define_vector_vector_operation(op, abrv, qabrv, dim)
  def {{op.id}}(other : Vector{{dim}}{{qabrv}}) : Vector{{dim}}{{abrv}}
    ovals = other.to_{{abrv}}.to_a
    Vector{{dim}}{{abrv}}.new(
      {% for i in 0...dim %}
        @v{{i}} {{op.id}} ovals[{{i}}],
      {% end %}
    )
  end
end

macro define_dot_product_method(klass, abrv, qabrv, dim)
  def dot(other : Vector{{dim}}{{qabrv}}) : {{klass}}
    snv = self.normalize.to_a
    onv = other.to_{{abrv}}.normalize.to_a
    snv.map_with_index { |sv, i| sv * onv[i] }.sum
  end
end

macro define_cross_product_method(abrv, qabrv, dim)
  def cross(other : Vector{{dim}}{{qabrv}}) : Vector{{dim}}{{abrv}}
    ovals = other.to_{{abrv}}.to_a
    Vector{{dim}}{{abrv}}.new(
      @v1 * ovals[2] - @v2 * ovals[1],
      @v2 * ovals[0] - @v0 * ovals[2],
      @v0 * ovals[1] - @v1 * ovals[0]
    )
  end
end

macro define_negate_method(abrv, dim)
  def negate : Vector{{dim}}{{abrv}}
    self * -1
  end
end

macro define_magnitude_method(klass)
  def magnitude : {{klass}}
    Math.sqrt(self.to_a.map { |v| v**2 }.sum)
  end
end

macro define_normalize_method(abrv, dim)
  def normalize : Vector{{dim}}{{abrv}}
    mag = self.magnitude
    Vector{{dim}}{{abrv}}.new(
      {% for i in 0...dim %}
        @v{{i}} / mag,
      {% end %}
    )
  end
end

macro define_to_s_method(dim)
  def to_s(io) : IO::FileDescriptor
    io << "<{ " 
    {% for i in 0...dim %} 
      io << @v{{i}} 
      {% if i != dim - 1 %} 
        io << ", " 
      {% else %} 
        io << " }>" 
      {% end %} 
    {% end %} 
  end
end

macro define_swizzle_operators(klass, abrv, dim)
  {% for quad, index in SWIZZLE_ARRAY %}
    {% for name_i, i in quad %}
      {% if i < dim %}
        def {{name_i}} : {{klass}}
          @v{{i}}
        end 
      {% end %}
      {% for name_j, j in quad %}
        {% if i < dim && j < dim %}
          def {{name_i}}{{name_j}} : Vector2{{abrv}}
            Vector2{{abrv}}.new(@v{{i}}, @v{{j}})
          end
        {% end %}
        {% for name_k, k in quad %}
          {% if i < dim && j < dim && k < dim %}
            def {{name_i}}{{name_j}}{{name_k}} : Vector3{{abrv}}
              Vector3{{abrv}}.new(@v{{i}}, @v{{j}}, @v{{k}})
            end
          {% end %}
          {% for name_l, l in quad %}
            {% if i < dim && j < dim && k < dim && l < dim %}
              def {{name_i}}{{name_j}}{{name_k}}{{name_l}} : Vector4{{abrv}}
                Vector4{{abrv}}.new(@v{{i}}, @v{{j}}, @v{{k}}, @v{{l}})
              end
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    {% end %}
  {% end %}
end

macro define_vector(klass, abrv, dim)
  struct Vector{{dim}}{{abrv}}
    define_instance_variables({{klass}}, {{dim}})
    define_initializer({{abrv}}, {{dim}})
    define_to_a_method({{klass}}, {{dim}})
    {% for op in OPERATORS %}
      define_scalar_operation({{op}}, {{abrv}}, {{dim}})
    {% end %}
    {% for qlass, qabrv in TYPE_HASH %}
      define_type_conversion_method({{qabrv}}, {{dim}})
      {% for op in [:+, :-] %}
        define_vector_vector_operation({{op}}, {{abrv}}, {{qabrv}}, {{dim}})
      {% end %}
      define_dot_product_method({{klass}}, {{abrv}}, {{qabrv}}, {{dim}})
      {% if dim == 3 %}
        define_cross_product_method({{abrv}}, {{qabrv}}, {{dim}})
      {% end %}
    {% end %}
    define_negate_method({{abrv}}, {{dim}})
    define_magnitude_method({{klass}})
    define_normalize_method({{abrv}}, {{dim}})
    define_to_s_method({{dim}})
    define_swizzle_operators({{klass}}, {{abrv}}, {{dim}})
  end
end

module Redemption
  {% for klass, abrv in TYPE_HASH %}
    {% for dim in DIM_ARRAY %}
      define_vector({{klass}}, {{abrv}}, {{dim}})
    {% end %}
  {% end %}
end