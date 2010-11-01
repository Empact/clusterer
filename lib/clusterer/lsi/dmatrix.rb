#--
###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Clusterer
  class DMatrix < Matrix
    #algorithm description from "Simple Algoritms for the partial singular value decomposition"
    #by J. C. Nash and S. Shlien
    #Plane rotation method
    #there were some typos in the original algorithm in the paper
    #also see the Pascal code in NashSVD, file alg01.pas; for an idea
    #the partial algorithm is an adaptation of that algo
    
    def svd
      m, n = self.row_size, self.column_size
      tol =  0.001
      slimit = [n/4.to_i, 6].max
      u, z, v = DMatrix[*(1..m).to_a.collect {|i| Array.new(n,0) }], Array.new(n), DMatrix.diagonal(*Array.new(n,1))

      nt = n
      slimit.times do
        rcount = nt *(nt-1)/2
        (nt-1).times do |j|
          (j+1).upto(nt - 1) do |k|
            p=q=r=0
            m.times do |i|
              p += self[i,j]*self[i,k]
              q += self[i,j]*self[i,j]
              r += self[i,k]*self[i,k]
            end
            z[j], z[k] = q, r
            if q < r
              p, q = p/r, q/r - 1
              vt = Math.sqrt(4*p*p + q*q)
              s = Math.sqrt(0.5*(1 - q/vt))
              s = -s if p < 0
              c = p / (vt*s)
            elsif  (q * r <= tol * tol) || (p/q)*(p/r) <= tol
              rcount -= 1
              next
            else
              p, r = p/q, 1 - r/q
              vt = Math.sqrt(4*p*p + r*r)
              c = Math.sqrt(0.5*(1 + r/vt))
              s = p/(vt * c)
            end
            m.times do |i|
              r = self[i,j]
              self[i,j] = c * r + s * self[i,k]
              self[i,k] = -s*r + c * self[i,k]
            end
            n.times do |i|
              r = v[i,j]
              v[i,j] = c * r + s * v[i,k] #typo in paper replace r by s 
              v[i,k] = -s*r + c * v[i,k]  #typo in paper replace A(i,k) by v(i,k)
            end
          end
        end
        until nt < 3 || z[nt-1]/(z[0] + tol) > tol
          nt -= 1
        end
        break unless rcount > 0
      end
      nt.times do |j|
        z[j] = Math.sqrt(z[j])
        m.times {|i| u[i,j] = self[i,j]/z[j] }
      end
      z = DMatrix.diagonal(*z)
      return u, z, v.transpose
    end

    def []=(i,j,val)
      @rows[i][j] = val
    end

    def self.join_rows(rows)
      DMatrix[*rows.collect {|r| [*r] }]
    end
    
    def transpose
      x = super
      y = DMatrix[]
      y.instance_variable_set("@rows",x.instance_variable_get("@rows"))
      y
    end
    
    def self.join_columns(columns)
      DMatrix[*columns.collect {|c| [*c] }].transpose
    end
  end
end

class Vector
  def transpose
    self
  end
  
  def dimensions
    [size]
  end

  def / (x)
    self * (1/x)
  end
end
