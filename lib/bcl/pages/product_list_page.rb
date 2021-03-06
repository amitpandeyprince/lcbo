module BCL
  class ProductListPage

    include CrawlKit::Page

    PER_PAGE = 100
    uri "http://www.bcliquorstores.com/product-catalogue?perPage={perPage}&page={page}"

    default_query_params \
      :perPage            => PER_PAGE.to_s,
      :page               => '1'
      # :STOCK_TYPE_NAME    => 'All',
      # :ITEM_NAME          => '',
      # :KEYWORDS           => '',
      # :ITEM_NUMBER        => '',
      # :productListingType => '',
      # :LIQUOR_TYPE_SHORT_ => '*',
      # :CATEGORY_NAME      => '*',
      # :SUB_CATEGORY_NAME  => '*',
      # :PRODUCING_CNAME    => '*',
      # :PRODUCING_REGION_N => '*',
      # :UNIT_VOLUME        => '*',
      # :SELLING_PRICE      => '*',
      # :LTO_SALES_CODE     => 'N',
      # :VQA_CODE           => 'N',
      # :KOSHER_CODE        => 'N',
      # :VINTAGES_CODE      => 'N',
      # :VALUE_ADD_SALES_CO => 'N',
      # :AIR_MILES_SALES_CO => 'N',
      # :language           => 'EN',
      # :style              => 'LCBO.css',
      # :sort               => 'sortedProduct',
      # :order              => '1',
      # :action             => 'result',
      # :sortby             => 'sortedProduct',
      # :orderby            => '',
      # :numPerPage         => PER_PAGE.to_s

    emits :page do
      body_params[:page].to_i
    end

    emits :final_page do
      @final_page ||= begin
        count = total_products / PER_PAGE
        0 == (total_products % PER_PAGE) ? count : count + 1
      end
    end

    emits :next_page do
      @next_page ||= begin
        page < final_page ? page + 1 : nil
      end
    end

    emits :total_products do
      @total_products ||= begin
        doc.css(".currentPage").first.text =~ /Viewing \d+-\d+ of (\d+) Matches/
        $1.to_i
      end
    end

    def product_ids
      doc.css("#product-catalogue-results-body .productImage-front a").map do |divs|
        divs['href'].split("/")[2]
      end
    end

    def products
      doc.css("#product-catalogue-results-body .productImage-front a").each do |divs|
        api_id = divs['href'].split("/")[2]
        yield BCL.product(api_id)
      end
    end

    def dox
      doc
    end

  end
end
