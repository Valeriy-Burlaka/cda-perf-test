# Contentful Technical Evaluation - Performance

Author(s): Valerii Burlaka

Status: DRAFT

Last updated: 2023-09-15

The document summarizes the results of a basic load test conducted on the Contentful Delivery API (**CDA**).

## Intention

Some [recent reports](https://docs.google.com/document/d/1nMyWiIBe_E2ry9HTML2dsABCZ0kHJPu7d2jYfEz4lSw/edit#heading=h.ws18f47rf5rb) (see the “Performance” section in the linked document) have highlighted potential long wait times (ranging from 10 to 25 seconds or more) when accessing the **CDA**.

While API performance can depend on numerous factors, such as cached vs. uncached requests, geographic location, and the complexity of the queries, the aim of this test was to conduct a preliminary examination.

By executing a few simple and focused test scenarios, the intention was to quickly verify whether there are any immediately apparent performance issues with the API, without delving into a comprehensive evaluation.

## Test Objective

The test aimed to evaluate the performance of the **CDA** REST endpoint under varying load conditions.

## Test Methodology

### Tools Used

* [Artillery.io](https://www.artillery.io/) - an open-source load testing tool.

### Test Environment

* Node.js v18.17.1
* MBP Pro, 2.6 GHz Intel Core-i7 (6 cores), 16GB RAM
* Network conditions:
  * Abstract speed test: 
    * Download: 144 Mbps/63 ms latency
    * Upload: 137 Mbpx/11 ms latency
  * <code>ping [https://cdn.contentful.com](https://cdn.contentful.com) </code> \
      <em>--- main.contentful.map.fastly.net ping statistics ---</em>

      <em>100 packets transmitted, 100 packets received, 0.0% packet loss</em>
        _round-trip min/avg/max/stddev = 27.328/46.190/73.449/13.728 ms_

### Test Scenarios

#### Fetch all entries

Submitting a series of GET requests to fetch all entries of a content type with pagination queries. Examples:

* [https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&limit=100&skip=0](https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&limit=100&skip=0)
* [https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&limit=100&skip=100](https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&limit=100&skip=0)

#### Search - short text field

Submitting a series of GET requests to perform a **full-text search** for entries with a specific phrase in their “**short** text field”. Example:

* [https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&fields.title[match]=crime](https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&limit=100&skip=0)

#### Search - long text field

Submitting a series of GET requests to perform a **full-text search** for entries with a specific phrase in their “**long** text field”. Example:

* [https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&fields.freebox[match]=domestic%20violence](https://cdn.contentful.com/spaces/{space_id}/environments/{env_id}/entries?content_type=toolboxItem&limit=100&skip=0)

### Test Phases

1. We create virtual users (**VU**) that will fetch the entire `toolboxItem` dataset with 4 subsequent GET requests using pagination queries (the dataset contained **372** entries at the moment).
2. We use different test phases to gradually ramp up the amount of **VUs** and then sustain the load. Different phases produce varying arrival rates and amount of concurrent requests to the **CDA**:
    1. **Warm up phase**:
        1. Duration: 10 seconds
        2. Arrival Rate: Starts with creating 1 **VU** per second and ramps up to creating 5 **VUs** per second (**VUs/s**).
    2. **Ramp Up**:
        3. Duration: 60 seconds
        4. Arrival Rate: Starts with 5 **VUs/s** and gradually increases to creating 10 **VUs/s**.
    3. **Sustain**:
        5. Duration: 120 seconds
        6. Arrival Rate: Maintains a steady load of creating 10 new **VUs/s**.
    4. **Ramp Up More**:
        7. Duration: 60 seconds
        8. Arrival Rate: Begins with 10 **VUs/s** and escalates to 20 **VUs/s**.
    5. **Sustain Previous Load**:
        9. Duration: 60 seconds
        10. Arrival Rate: Sustains the previous load at 20 **VUs/s**.

## Test Results

### Fetch all entries

#### Summarized Findings

* Total **VUs** created: **3780**
* **VU** failed: **0** (All **VUs** finished their test scenario successfully)
* Total HTTP requests made: **15120**
* All requests received a **200** status code.
* Total data downloaded: **1.255** GB
* Average request rate: **55** requests/s.
* Max request rate: **90** requests/s.

#### Response Time Statistics

<table>
  <tr>
   <td><strong>Metric</strong>
   </td>
   <td><strong>Min</strong>
   </td>
   <td><strong>Max</strong>
   </td>
   <td><strong>Median</strong>
   </td>
   <td><strong>p90</strong>
   </td>
   <td><strong>p95</strong>
   </td>
   <td><strong>p99</strong>
   </td>
  </tr>
  <tr>
   <td>HTTP Response Time (ms)
   </td>
   <td>19
   </td>
   <td>357
   </td>
   <td>30.3
   </td>
   <td>32.8
   </td>
   <td>36.2
   </td>
   <td>48.9
   </td>
  </tr>
  <tr>
   <td>Session Length (ms)<strong>*</strong>
   </td>
   <td>211.9
   </td>
   <td>1601.6
   </td>
   <td>301.9
   </td>
   <td>327.1
   </td>
   <td>340.4
   </td>
   <td>391.6
   </td>
  </tr>
</table>

*** **A **session** means a complete test flow - executing all requests specified in a test **scenario**.

#### Anomalies or Unexpected Findings

None.

### Search - short text field

#### Summarized Findings

* Total **VUs** created: **3780**
* **VU** failed: **0** (All **VUs** finished their test scenario successfully)
* Total HTTP requests made: **11340**
* All requests received a **200** status code.
* Total data downloaded: **0.05** GB
* Average request rate: **42** requests/s.
* Max request rate: **60** requests/s.

#### Response Time Statistics

<table>
  <tr>
   <td><strong>Metric</strong>
   </td>
   <td><strong>Min</strong>
   </td>
   <td><strong>Max</strong>
   </td>
   <td><strong>Median</strong>
   </td>
   <td><strong>p90</strong>
   </td>
   <td><strong>p95</strong>
   </td>
   <td><strong>p99</strong>
   </td>
  </tr>
  <tr>
   <td>HTTP Response Time (ms)
   </td>
   <td>19
   </td>
   <td>185
   </td>
   <td>29.1
   </td>
   <td>32.8
   </td>
   <td>34.8
   </td>
   <td>48.9
   </td>
  </tr>
  <tr>
   <td>Session Length (ms)<strong>*</strong>
   </td>
   <td>137.7
   </td>
   <td>722.6
   </td>
   <td>194.4
   </td>
   <td>210.6
   </td>
   <td>223.7
   </td>
   <td>257.3
   </td>
  </tr>
</table>

#### Anomalies or Unexpected Findings

None.

### Search - long text field

#### Summarized Findings

* Total **VUs** created: **3780**
* **VU** failed: **0** (All **VUs** finished their test scenario successfully)
* Total HTTP requests made: **7560**
* All requests received a **200** status code.
* Total data downloaded: **0.28** GB
* Average request rate: **31** requests/s.
* Max request rate: **40** requests/s.

#### Response Time Statistics

<table>
  <tr>
   <td><strong>Metric</strong>
   </td>
   <td><strong>Min</strong>
   </td>
   <td><strong>Max</strong>
   </td>
   <td><strong>Median</strong>
   </td>
   <td><strong>p90</strong>
   </td>
   <td><strong>p95</strong>
   </td>
   <td><strong>p99</strong>
   </td>
   <td><strong>p999</strong>
   </td>
  </tr>
  <tr>
   <td>HTTP Response Time (ms)
   </td>
   <td>19
   </td>
   <td>197
   </td>
   <td>26.8
   </td>
   <td>32.8
   </td>
   <td>36.2
   </td>
   <td>51.9
   </td>
   <td>156
   </td>
  </tr>
  <tr>
   <td>Session Length (ms)<strong>*</strong>
   </td>
   <td>141.3
   </td>
   <td>1185.4
   </td>
   <td>179.5
   </td>
   <td>210.6
   </td>
   <td>228.2
   </td>
   <td>368.8
   </td>
   <td>804.5
   </td>
  </tr>
</table>

#### Anomalies or Unexpected Findings

**Potential anomalies**: High percentile durations (the 99th and 999th percentiles).

The **99th** percentile (**p99**) jumps to **368.8** ms, showing that the session lengths can vary significantly in the tail. This might be a point of interest for further investigation.

The **99.9th** percentile (**p999**) is at **804.5** ms. This can represent some extreme edge cases and could be important if we will have strict performance requirements for toolbox & resources feature.

## Interpretation of the Results and Conclusion

The Contentful API performed consistently throughout the test with all requests returning successful responses. The median response time _seems to be_ within an acceptable limit, even at higher percentiles, and there was no significant degradation of performance with the simulated load.

## Considerations for Further Testing and Research

* Test search API further:
  * Search inside Rich Text fields;
  * Search by tags;
  * Submit more search queries in a sequence (look for potential edge cases in search performance).
* Testing with larger datasets
* Evaluating performance in different network conditions? (although, they should be better in service-to-service environments)
* Testing uncached queries? (**CDA** caches its responses by default, so we should rarely miss the cache in real-life.)

## Appendices

### Code Snippets Used for Testing

#### Artillery Configs

```yaml
# test-get-all-toolbox-entries.yaml

# test-search-toolbox-items-short-text.yaml

# test-search-toolbox-items-long-text.yaml

```

### Links to Test Reports

#### Fetch all entries

* [JSON](./test-reports/test-report__pagination__15.09.json)
* [HTML](./test-reports/test-report__pagination__15.09.html)

#### Search - short text field

* [JSON](./test-reports/test-report__search-short-text__18.09.json)
* [HTML](./test-reports/test-report__search-short-text__18.09.html)

#### Search - long text field

* [JSON](./test-reports/test-report__search-long-text__18.09.json)
* [HTML](./test-reports/test-report__search-long-text__18.09.html)
