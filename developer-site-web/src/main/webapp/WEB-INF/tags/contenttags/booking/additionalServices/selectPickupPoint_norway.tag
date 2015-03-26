<div>
    <h4>Delivery to Pickup Point in Norway</h4>
    <p>
        You can specify pickup point Id in request for SERVICEPAKKE and CARRYON_HOMESHOPPING_BULKSPLIT products for delivery of parcels within Norway and to Norway from other countries.
        Use <a  href="http://developer.bring.com/api/pickuppointapi.html#xml"> Pickup Point API </a>to get list of nearest pickup points.
    </p>
    <p>
        The parcel will be delivered to the pickup point specified in the request with SMS/Email notification.
        Recipient phone no and email address is mandatory if using pickup point delivery as it is required for notification.
    </p>
    <p>
        Pickup point id and country code has to be specified under <strong>pickupPoint</strong> element within <strong>parties</strong> element as shown below.
    </p>
</div>