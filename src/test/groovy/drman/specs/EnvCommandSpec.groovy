package drman.specs

import drman.support.DRmanEnvSpecification

class EnvCommandSpec extends DRmanEnvSpecification {

	def setup() {
		bash = DRmanBashEnvBuilder
				.withVersionCache("x.y.z")
				.withOfflineMode(true)
				.build()
		bash.start()
		bash.execute("source $bootstrapScript")
	}

	def "should use the candidates contained in .drmanrc"() {
		given:
		new FileTreeBuilder(candidatesDirectory).with {
			"grails" {
				"2.1.0" {}
			}
			"groovy" {
				"2.4.1" {}
			}
		}

		new File(bash.workDir, '.drmanrc').text = drmanrc

		when:
		bash.execute("sdk env")

		then:
		verifyAll(bash.output) {
			contains("Using groovy version 2.4.1 in this shell.")
			contains("Using grails version 2.1.0 in this shell.")
		}

		where:
		drmanrc << ["grails=2.1.0\ngroovy=2.4.1", "grails=2.1.0\ngroovy=2.4.1\n"]
	}

	def "should issue an error if .drmanrc contains malformed candidate entries"() {
		given:
		new File(bash.workDir, '.drmanrc').text = "groovy 2.4.1"

		when:
		bash.execute("sdk env")

		then:
		verifyAll(bash) {
			status > 0
			output.contains("Invalid candidate format!")
		}
	}
}
