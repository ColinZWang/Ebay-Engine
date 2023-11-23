const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;

// eBay credentials
const EBAY_API_ENDPOINT = 'https://svcs.ebay.com/services/search/FindingService/v1';
const EBAY_API_KEY = 'ZixiWang-dummy2-PRD-ef4b751c9-2b501754';

// Update your Google API Key and Search Engine ID
const API_KEY = 'AIzaSyBungfBhRx7EXYEAFdyzygNAQwD9UZ14ZY';
const SEARCH_ENGINE_ID = '33aff5545c7c147d6';

const OAuthToken = require('./ebay_oauth_token.js');

// Initialize with your client id and client secret
CLIENT_ID = 'ZixiWang-dummy2-PRD-ef4b751c9-2b501754'
CLIENT_SECRET = 'PRD-f4b751c9bfe9-0c48-40d9-87bd-81ee'
const oauth = new OAuthToken(CLIENT_ID, CLIENT_SECRET);

// Fetch and store the token in memory
let eBayToken = oauth.getApplicationToken();


const EBAY_CATEGORY_MAP = {
  "Art": "550",
  "Baby": "2984",
  "Books": "267",
  "Clothing, Shoes & Accessories": "11450",
  "Computers/Tablets & Networking": "58058",
  "Health & Beauty": "26395",
  "Music": "11233",
  "Video Games & Consoles": "1249"
};

const mongoose = require('mongoose');

const password = '770sGrandAve7058';
const MONGODB_URI = `mongodb+srv://ColinZWang:${password}@colinzwang-cluster.6civtdf.mongodb.net/?retryWrites=true&w=majority`;

app.get('/getUserLocation', async (req, res) => {
  try {
      const response = await axios.get(`https://ipinfo.io/json?token=21c03b02289dce`);
      console.log('IP Info:',response)
      res.send(response.data.postal);
  } catch (error) {
      console.error('Error fetching location:', error);
      res.status(500).send('Error fetching location');
  }
});


console.log("Attempting to connect to MongoDB...");

mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverApi: {
    version: '1',
    strict: true,
    deprecationErrors: true
  }
});

mongoose.connection.once('open', function() {
  console.log("Successfully connected to MongoDB.");
}).on('error', function(error) {
  console.log("Connection error:", error);
});

const wishListItemSchema = new mongoose.Schema({
  itemId: String,
  image: String,
  title: String,
  price: String,
  shipping: String,
  zip: String
});

const WishListItem = mongoose.model('WishListItem', wishListItemSchema);


app.use(cors()); // To allow cross-origin requests
app.use(express.json());

//...[other imports]

app.get('/search', (req, res) => {
  const params = req.query;

  const ebayURL = new URL(EBAY_API_ENDPOINT);
  ebayURL.searchParams.set('OPERATION-NAME', 'findItemsAdvanced');
  ebayURL.searchParams.set('SERVICE-VERSION', '1.0.0');
  ebayURL.searchParams.set('SECURITY-APPNAME', EBAY_API_KEY);
  ebayURL.searchParams.set('RESPONSE-DATA-FORMAT', 'JSON');
  ebayURL.searchParams.set('REST-PAYLOAD', '');
  ebayURL.searchParams.set('paginationInput.entriesPerPage', '50');
  ebayURL.searchParams.set('keywords', params.keyword);
  ebayURL.searchParams.set('buyerPostalCode', params.zipcode);

  if (params.category) {
    const ebayCategory = EBAY_CATEGORY_MAP[params.category];
    if (ebayCategory) {
        ebayURL.searchParams.set('categoryId', ebayCategory);
    }
  }


  let filterIndex = 0;
  if (params.distance) {
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).name`, 'MaxDistance');
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).value`, params.distance);
    filterIndex++;
  }
  if (params.freeshipping) {
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).name`, 'FreeShippingOnly');
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).value`, 'true');
    filterIndex++;
  }
  if (params.localpickup) {
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).name`, 'LocalPickupOnly');
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).value`, 'true');
    filterIndex++;
  }
  
  ebayURL.searchParams.set(`itemFilter(${filterIndex}).name`, 'HideDuplicateItems');
  ebayURL.searchParams.set(`itemFilter(${filterIndex}).value`, 'true');
  filterIndex++;

  let conditionValueIndex = 0;
  if (params.newCondition || params.usedCondition || params.unspecifiedCondition){
    ebayURL.searchParams.set(`itemFilter(${filterIndex}).name`, 'Condition');

    if (params.newCondition) {
        ebayURL.searchParams.set(`itemFilter(${filterIndex}).value(${conditionValueIndex++})`, '1000'); // New
    }
    if (params.usedCondition) {
        ebayURL.searchParams.set(`itemFilter(${filterIndex}).value(${conditionValueIndex++})`, '3000'); // Used
        ebayURL.searchParams.set(`itemFilter(${filterIndex}).value(${conditionValueIndex++})`, '4000');
        ebayURL.searchParams.set(`itemFilter(${filterIndex}).value(${conditionValueIndex++})`, '5000');
        ebayURL.searchParams.set(`itemFilter(${filterIndex}).value(${conditionValueIndex++})`, '6000');

    }
    if (params.unspecifiedCondition) {
      ebayURL.searchParams.set(`itemFilter(${filterIndex}).value(${conditionValueIndex++})`, 'Unspecified');
    }
  }
  

  ebayURL.searchParams.set('outputSelector(0)', 'SellerInfo');
  ebayURL.searchParams.set('outputSelector(1)', 'StoreInfo');


  console.log('Sending Ebay URL: ',ebayURL)

  axios.get(ebayURL.href)
    .then(response => {
        const data = response.data.findItemsAdvancedResponse[0];
        const searchResultItems = data.searchResult[0].item || [];

        // Extracting the required values from the response
        const extractedResults = searchResultItems.map((item, index) => {
          let condition = 'NA';
                const conditionId = item.condition && item.condition[0].conditionId && item.condition[0].conditionId[0];
                switch(conditionId) {
                    case '1000': condition = 'NEW'; break;
                    case '2000':
                    case '2500': condition = 'REFURBISHED'; break;
                    case '3000':
                    case '4000':
                    case '5000':
                    case '6000': condition = 'USED'; break;
                    default: condition = 'NA';
                }
            return {
                index: index + 1,
                itemId: item.itemId && item.itemId[0],
                image: item.galleryURL && item.galleryURL[0],
                title: item.title && item.title[0],
                price: item.sellingStatus && item.sellingStatus[0].currentPrice && item.sellingStatus[0].currentPrice[0].__value__,
                shipping: (item.shippingInfo && item.shippingInfo[0].shippingServiceCost && parseFloat(item.shippingInfo[0].shippingServiceCost[0].__value__) === 0.0) ? "Free Shipping" : 
                          (item.shippingInfo && item.shippingInfo[0].shippingServiceCost ? `$${item.shippingInfo[0].shippingServiceCost[0].__value__}` : "N/A"),
                zip: item.postalCode && item.postalCode[0],
                condition: condition
            };
        });

        if (!extractedResults || extractedResults.length === 0) {
          console.log("No Results Found, Sending Back Empty Array")
          return res.json([]); // Send an empty array if no results
        }

        console.log("First Result: ",extractedResults[0]); 
        res.json(extractedResults);
    })
    .catch(error => {
        res.status(500).json({ message: 'Error making request to eBay', error: error.message });
    });
});

app.post('/wishlist', async (req, res) => {
  console.log("POST request received for /wishlist with data:", req.body);

  const item = new WishListItem(req.body);
  try {
    const savedItem = await item.save();
    console.log("Item saved successfully:", savedItem);
    res.status(200).send(savedItem);
  } catch (err) {
    console.error("Error saving wishlist item:", err);
    res.status(500).send(err);
  }
});

app.get('/wishlist', async (req, res) => {
  console.log("GET request received for /wishlist");

  try {
    const items = await WishListItem.find({});
    // console.log("Fetched wishlist items:", items);
    res.status(200).send(items);
  } catch (err) {
    console.error("Error fetching wishlist items:", err);
    res.status(500).send(err);
  }
});

app.delete('/wishlist/:id', async (req, res) => {
  console.log(`DELETE request received for /wishlist/${req.params.id}`);

  try {
    await WishListItem.findByIdAndDelete(req.params.id);
    console.log(`Item with ID ${req.params.id} removed successfully.`);
    res.status(200).send({ message: 'Item removed.' });
  } catch (err) {
    console.error("Error deleting wishlist item:", err);
    res.status(500).send(err);
  }
});

app.get('/product/:itemId', async (req, res) => {
  const itemId = req.params.itemId;
  console.log("Backend received Item ID:", itemId);

  // Define constants
  const EBAY_API_ENDPOINT = 'https://open.api.ebay.com/shopping';

  // Construct the URL with search parameters
  const ebayURL = new URL(EBAY_API_ENDPOINT);
  ebayURL.searchParams.set('callname', 'GetSingleItem');
  ebayURL.searchParams.set('responseencoding', 'JSON');
  ebayURL.searchParams.set('appid', EBAY_API_KEY);
  ebayURL.searchParams.set('siteid', '0');
  ebayURL.searchParams.set('version', '967');
  ebayURL.searchParams.set('ItemID', itemId);
  ebayURL.searchParams.set('IncludeSelector', 'Description,Details,ItemSpecifics');

  console.log('Constructed eBay API URL:', ebayURL.toString());

  const headers = {
    'X-EBAY-API-IAF-TOKEN': await oauth.getApplicationToken()
  };
  
  // Use the constructed URL and headers for your API call
  try {
    const response = await axios.get(ebayURL.toString(), { headers: headers });
    // Extract required details from the eBay API response
    const item = response.data.Item;  // Assuming the response object has an 'Item' attribute
    const productDetails = {
        Title: item.Title,
        ProductImages: item.PictureURL,
        Price: item.CurrentPrice?.Value,
        Location: item.Location,
        ItemSpecifics: item.ItemSpecifics.NameValueList,
        ReturnPolicy: {
            ReturnsAccepted: item.ReturnPolicy?.ReturnsAccepted,
            ReturnsWithin: item.ReturnPolicy?.ReturnsWithin
        },
        handlingTime: item.HandlingTime,
        shippingServiceCost: item.ShippingCostSummary?.ShippingServiceCost,
        shipToLocations: item.ShipToLocations,
        expeditedShipping: item.ShippingCostSummary?.ExpeditedShipping,
        oneDayShippingAvailable: item.ShippingCostSummary?.OneDayShippingAvailable,
        FeedbackScore: item.Seller?.FeedbackScore,
        PositiveFeedbackPercent: item.Seller?.PositiveFeedbackPercent,
        FeedbackRatingStar: item.Seller?.FeedbackRatingStar,
        TopRatedSeller: item.Seller?.TopRatedSeller,
        StoreName: item.Storefront?.StoreName,
        StoreURL: item.Storefront?.StoreURL

    };

    console.log(productDetails);
    res.json(productDetails);
} catch (error) {
    console.error('Error fetching data from eBay API:', error);
    res.status(500).send('Internal server error');
}


});

app.get('/photos', async (req, res) => {
  const { productTitle } = req.query;

  if (!productTitle) {
    return res.status(400).send('Product title is required');
  }

  try {
    const response = await axios.get('https://www.googleapis.com/customsearch/v1?', {
      params: {
        q: productTitle.slice(0, 20),
        cx: SEARCH_ENGINE_ID,
        imgSize: 'huge',
        imgType: 'photo',
        num: 8,
        searchType: 'image',
        key: API_KEY
      }
    });

    if (response.data.items) {
      const imageLinks = response.data.items.map(item => item.link);
      res.json(imageLinks);
    } else {
      res.status(404).send('No images found');
    }
  } catch (error) {
    console.error('Error fetching photos:', error.response ? error.response.data : error.message);
    res.status(500).send(error.response ? error.response.data : 'Internal Server Error');
  }
});




app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});