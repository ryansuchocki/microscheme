# Maintainer: Ryan Suchocki <ryan <at> ryansuchocki <dot> co <dot> uk>
pkgname=microscheme
pkgver=0.9.2
pkgrel=1
pkgdesc="A Scheme subset designed for Atmel microcontrollers, especially as found on Arduino boards"
arch=('any')
url="http://microscheme.org"
license=('MIT')
groups=()
depends=('glibc' 'avr-gcc' 'avrdude')
makedepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=('https://github.com/ryansuchocki/microscheme/archive/v0.9.2.tar.gz')
noextract=()
md5sums=('29e7db436b2e1c6821ed1c6fe70534a2')

build() {
  cd "$pkgname-$pkgver"
  make all
}

package() {
	cd "$pkgname-$pkgver"
	make PREFIX="$pkgdir/usr" install
	install -D -m644 LICENSE "${pkgdir}/usr/share/licenses/$pkgname/LICENSE"
}
