// CHORD upchannelization kernel

#include <algorithm>
#include <array>
#include <cassert>
#include <cmath>
#include <complex>
#include <iostream>
#include <vector>

constexpr int C = 2;     // number of complex components
constexpr int T = 32768; // number of times
constexpr int D = 1;     // TODO 512;   // number of dishes
constexpr int P = 1;     // TODO 2;     // number of polarizations
constexpr int F = 1;     // TODO 16;    // frequency channels per GPU
constexpr int U = 16;    // upchannelization factor
constexpr int M = 4;     // number of taps

// 4-bit integers

using int4x2_t = uint8_t;

constexpr int4x2_t set4(const int8_t lo, const int8_t hi) {
  return (uint8_t(lo) & 0x0f) | ((uint8_t(hi) << 4) & 0xf0);
}
constexpr int4x2_t set4(const std::array<int8_t, 2> a) {
  return set4(a[0], a[1]);
}

constexpr std::array<int8_t, 2> get4(const int4x2_t i) {
  return {int8_t(int8_t((i + 0x08) & 0x0f) - 0x08),
          int8_t(int8_t(((i >> 4) + 0x08) & 0x0f) - 0x08)};
}

constexpr bool test_get4_set4() {
  for (int hi = -8; hi <= 7; ++hi) {
    for (int lo = -8; lo <= 7; ++lo) {
      if (get4(set4(lo, hi))[0] != lo)
        return false;
      if (get4(set4(lo, hi))[1] != hi)
        return false;
    }
  }
  return true;
}

static_assert(test_get4_set4());

// 16-bit floats

using float16_t = _Float16;

template <typename T, typename I> constexpr T convert(const I i) {
  return T(i);
}
template <typename T, typename I>
constexpr std::complex<T> convert(const std::complex<I> i) {
  return std::complex<T>(convert<I>(i.real()), convert<I>(i.imag()));
}

template <typename I, typename T>
constexpr I quantize(const T x, const I imax) {
  using std::floor;
  const I itmp = I(floor(x + T(0.5)));
  using std::max, std::min;
  const I i = min(imax, max(I(-imax), itmp));
  return i;
}
template <typename I, typename T>
constexpr std::complex<I> quantize(const std::complex<T> x, const I imax) {
  return std::complex<I>(quantize<I>(x.real(), imax),
                         quantize<I>(x.imag(), imax));
}

// complex numbers

template <typename T>
constexpr std::complex<T> to_complex(const std::array<T, 2> a) {
  return std::complex<T>(a[1], a[0]);
}
template <typename T>
constexpr std::array<T, 2> to_array(const std::complex<T> c) {
  return std::array<T, 2>{c.imag(), c.real()};
}

// functions
template <typename T> constexpr T sinc(const T x) {
  return x == T(0) ? T(1) : sin(x) / x;
}

// array indexing

constexpr int Eidx(int c, int d, int f, int p, int t) {
  assert(t >= 0 && t < T + M * U - 1);
  return d + D * f + D * F * p + D * F * P * t;
}

constexpr int Ebaridx(int c, int d, int fbar, int p, int tbar) {
  assert(tbar >= 0 && tbar < T / U);
  return d + D * fbar + D * F * U * p + D * F * U * P * tbar;
}

// kernel

void upchan_simple(const float16_t *__restrict__ const W,
                   const float16_t *__restrict__ const G,
                   const int4x2_t *__restrict__ const E,
                   int4x2_t *__restrict__ const Ebar) {
#pragma omp parallel for collapse(5)
  for (int f = 0; f < F; ++f) {
    for (int p = 0; p < P; ++p) {
      for (int d = 0; d < D; ++d) {
        for (int u = 0; u < U; ++u) {
          for (int tbar = 0; tbar < T / U; ++tbar) {

            const int fbar = u + f * U;

            std::complex<float> Ebar1 = 0.0f;

            for (int s = 0; s < M * U; ++s) {
              const int t = s + U * tbar;

              const float W1 = W[s];

              using std::polar;
              const std::complex<float> phase1 =
                  polar(1.0f, float(M_PI) * s * (U - 1) / U);
              const std::complex<float> phase2 =
                  polar(1.0f, -2 * float(M_PI) * u * s / U);

              const std::complex<float> E1 =
                  convert<float>(to_complex(get4(E[Eidx(0, d, f, p, t)])));

              Ebar1 += W1 * phase1 * phase2 * E1;

            } // s

            const float G1 = G[u];
            Ebar1 *= G1;
            Ebar[Ebaridx(0, d, fbar, p, tbar)] =
                set4(to_array(quantize<int8_t>(Ebar1, 7)));

          } // tbar
        }   // u
      }     // d
    }       // p
  }         // f
}

// driver

int main(int argc, char **argv) {
  std::cout << "CHORD upchannelization kernel\n";

  std::cout << "Initializing input...\n";
  std::vector<float16_t> W(M * U); // PFB weight function
  std::vector<float16_t> G(U);     // output gains
  std::vector<int4x2_t> E(C * D * F * P * (T + M * U - 1) /
                          2); // electric field
  std::vector<int4x2_t> Ebar(C * D * F * P * T /
                             2); // upchannelized electric field
  using std::cos, std::pow, std::sin;
  for (int s = 0; s < M * U; ++s)
    // sinc-Hanning weight function, eqn. (11), with `N=U`, and with `M*U`
    // changed to `M*U-1`
    W.at(s) =
        pow(cos(float(M_PI) * (s - (M * U - 1) / 2.0f) / (M * U - 1)), 2) *
        sinc((s - (M * U - 1) / 2.0f) / U);
  for (int u = 0; u < U; ++u)
    G.at(u) = 1;
  for (int t = 0; t < T + M * U - 1; ++t) {
    for (int p = 0; p < P; ++p) {
      for (int f = 0; f < F; ++f) {
        for (int d = 0; d < D; ++d) {
          using std::polar;
          // const std::complex<float> E1 = 0.0f;
          // const std::complex<float> E1 = 1.0f;
          // const std::complex<float> E1 =
          //     polar(7.0f, 2 * float(M_PI) * t / (T / U));
          const std::complex<float> E1 = t == 0 ? 1.0f : 0.0f;
          E.at(Eidx(0, d, f, p, t)) = set4(to_array(quantize<int8_t>(E1, 7)));
        }
      }
    }
  }
  for (int tbar = 0; tbar < T / U; ++tbar)
    for (int p = 0; p < P; ++p)
      for (int fbar = 0; fbar < F * U; ++fbar)
        for (int d = 0; d < D; ++d)
          Ebar.at(Eidx(0, d, fbar, p, tbar)) = set4(-8, -8);

  std::cout << "Calling kernel...\n";
  upchan_simple(W.data(), G.data(), E.data(), Ebar.data());

  std::cout << "Checking output...\n";
  int num_errors = 0;
  for (int fbar = 0; fbar < F * U; ++fbar) {
    for (int p = 0; p < P; ++p) {
      for (int d = 0; d < D; ++d) {
        for (int tbar = 0; tbar < T / U; ++tbar) {
          const std::complex<int> Ebar1 = std::complex<int>(
              to_complex(get4(Ebar.at(Eidx(0, d, fbar, p, tbar)))));
          if (Ebar1 != 0) {
            std::cout << "  d=" << d << " fbar=" << fbar << " p=" << p
                      << " tbar=" << tbar << " Ebar=" << Ebar1 << "\n";
            ++num_errors;
          }
        }
      }
    }
  }
  if (num_errors > 0)
    std::cout << "ERRORS FOUND: " << num_errors << "\n";

  std::cout << "Done.\n";
  return 0;
}
