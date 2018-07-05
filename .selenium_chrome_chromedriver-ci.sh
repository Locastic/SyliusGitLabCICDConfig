apt-get install xvfb unzip curl -y
rm -rf /opt/chromedriver
rm -rf /opt/selenium/
rm -rf /opt/google/

/sbin/start-stop-daemon --start --quiet --pidfile /tmp/xvfb_10.pid --make-pidfile --background --exec /usr/bin/xvfb-run -- :10 -ac -screen 0 1920x1080x24
export DISPLAY=:10

# Download and install Google Chrome
if [ ! -f "/opt/google/chrome/google-chrome" ] || [ "(/opt/google/chrome/google-chrome --version | grep -c 67" = "0" ]; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qqy \
    && apt-get -qqy install google-chrome-stable \
    && sed -i 's/"$HERE\/chrome"/"$HERE\/chrome" --headless --no-sandbox/g' /opt/google/chrome/google-chrome
fi

# Download and configure ChromeDriver
if [ ! -f "/opt/chromedriver" ] || [ "(/opt/chromedriver --version | grep -c 2.38" = "0" ]; then
    curl http://chromedriver.storage.googleapis.com/2.38/chromedriver_linux64.zip > chromedriver.zip
    unzip chromedriver.zip
    chmod +x chromedriver
    mv chromedriver /opt/chromedriver
fi

# Run ChromeDriver
/opt/chromedriver > /dev/null 2>&1 &

# Download and configure Selenium
if [ ! -f "/opt/selenium.jar" ] || [ "$(java -jar /opt/selenium.jar --version | grep -c 3.11.0)" = "0" ]; then
    curl http://selenium-release.storage.googleapis.com/3.11/selenium-server-standalone-3.11.0.jar > selenium.jar
    mv selenium.jar /opt/selenium.jar
fi

# Run Selenium
java -Dwebdriver.chrome.driver=/opt/chromedriver -jar /opt/selenium.jar > /dev/null 2>&1 &

