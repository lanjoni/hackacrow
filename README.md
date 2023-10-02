# hackacrow

Have you ever been interested in a practical and simple way to perform tests for multiple programming languages on multiple occasions? Well, this case fits very well into examples of hackathons in which we can have multiple programming languages to solve different exercises. The objective of hackacrow is to be a tool that will allow you to run tests in a simple way, with expected inputs and outputs informed via JSON, in a simple way!

## Installation

Okay, now is the time to carry out the installation! You can download the binaries and send them to your favorite location (such as `/usr/bin` or a specific directory) and you can now use them!

Installation with Crystal is also very simple, just have Crystal (and Shards) previously installed and then run:
```sh
shards build --release
```

Done! Now in the `./bin` directory we will have an executable named `hackacrow`! Use wisely and enjoy!

## Usage

What types of commands can I run? Well, as the main functionality is to run tests, you will therefore enter the name of the file you want to run and the exercise number (in this case, there is a JSON for expected inputs and outputs found in `./expect/expect.json` , being an array)!

Ok, but you might be wondering "don't I need to enter the language I want to run"? No! Hackacrow automatically checks the extension of the file to be executed in another JSON file found in `./lang/lang.json`, knowing exactly which command to use!

If you want to test, there are two sample files! Just run:
```sh
shards build --release && ./bin/hackacrow -c 1 ./samples/1.cr
```
> Note: The `-c` flag is used to check the output of a command, in this case `1` would be the exercise and `./samples/1.cr` the name of the file to be tested!

## Development

Contributions are **extremely appreciated**! We currently have some issues open [here](https://github.com/lanjoni/hackacrow/issues), so development is always active!

Don't know Crystal? Come and see, the community is incredible and the syntax is extremely elegant (like Ruby) with the performance of a compiled language!

Do you know Ruby? Then you know Crystal! Just read a few lines of code and you will understand how they are very similar!

Why Crystal? Because Crystal is incredible, brilliant has an absurd performance! Try giving it a try, I'm sure you won't regret it!

## Contributing

1. Fork it (<https://github.com/lanjoni/hackacrow/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [@lanjoni](https://github.com/lanjoni) - creator and maintainer
